#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2021-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

# --- Script for Local PKI Setup and Certificate Management ---

# --- Robustness Settings ---
set -euo pipefail # Exit on error, exit on unset variables, fail if any command in a pipe fails.
IFS=$'\n\t'       # Preserve newlines and tabs in word splitting.

# --- Terminal Colors ---
LRED='\033[1;31m'
LGREEN='\033[1;32m'
LBLUE='\033[1;34m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Configuration Variables ---
WORKDIR="/mnt/clusterfs/openssl/ca-bitsmasher.net"
OPENSSL_CONFIG="${WORKDIR}/openssl.cnf" # Explicitly define config file path
ROOT_CA_KEY="${WORKDIR}/private/root-ca.key"
ROOT_CA_CRT="${WORKDIR}/certs/root-ca.crt"
INTERMEDIATE_CA_KEY="${WORKDIR}/private/intermediate-ca.key"
INTERMEDIATE_CA_CSR="${WORKDIR}/csr/intermediate-ca.csr"
INTERMEDIATE_CA_CRT="${WORKDIR}/certs/intermediate-ca.crt"

# Define your desired hosts. Use an associative array for hostname to IP mapping.
# This makes the machine_certs function more robust and self-contained.
declare -A DEB_HOSTS=(
    ["head2"]="10.10.12.19"
    ["ldap"]="10.10.12.20" # Example, replace with actual IPs
    ["node0"]="10.10.12.21"
    ["node1"]="10.10.12.22"
    ["node2"]="10.10.12.23"
    ["node3"]="10.10.12.24"
    ["node5"]="10.10.12.25"
    ["node6"]="10.10.12.26"
    ["ns1"]="10.10.12.27"
    ["snowy"]="10.10.12.28"
    ["thelio"]="10.10.12.29"
    ["time"]="10.10.12.30"
)

# --- Helper Functions for Logging ---
log_header() {
    echo -e "\n${LPURP}# --- $1 ${NC}"
}

log_info() {
    echo -e "${LBLUE}$1${NC}"
}

log_success() {
    echo -e "${LGREEN}$1${NC}"
}

log_error() {
    echo -e "${LRED}ERROR: $1${NC}" >&2
    exit 1
}

# --- Core Functions ---

function create_pki_structure() {
    log_header "Creating PKI directory structure"
    log_info "Ensuring base directory ${WORKDIR} exists..."
    mkdir -p "${WORKDIR}" || log_error "Failed to create ${WORKDIR}"

    log_info "Initializing CA files: index.txt and serial..."
    touch "${WORKDIR}/index.txt" || log_error "Failed to create index.txt"
    # Initialize serial to 1000 if it doesn't exist or is empty
    if [ ! -f "${WORKDIR}/serial" ] || [ -z "$(cat "${WORKDIR}/serial")" ]; then
        echo "1000" >"${WORKDIR}/serial" || log_error "Failed to write to serial file"
    fi

    log_info "Creating subdirectories for certificates, CRLs, CSRs, and private keys..."
    mkdir -p "${WORKDIR}/certs" "${WORKDIR}/crl" "${WORKDIR}/newcerts" "${WORKDIR}/private" "${WORKDIR}/csr" || log_error "Failed to create subdirectories"

    # Symlink openssl.cnf if it's not already linked or copied
    if [ ! -f "${WORKDIR}/openssl.cnf" ] || [ ! -L "${WORKDIR}/openssl.cnf" ]; then
        log_info "Linking ${WORKDIR}/openssl.cnf to ${OPENSSL_CONFIG}"
        ln -s ${WORKDIR}/openssl.cnf "${OPENSSL_CONFIG}" || log_error "Failed to link openssl.cnf"
    else
        log_info "openssl.cnf already linked/present at ${OPENSSL_CONFIG}"
    fi

    log_success "PKI structure created successfully."
}

# No need for setup_cfssl if not using cfssl commands directly.
# Removed ansible_kludge, assuming files are in place or handled externally.

function generate_root_ca_key() {
    log_header "Generating Root CA Private Key"
    if [ ! -f "${ROOT_CA_KEY}" ]; then
        log_info "Creating ${ROOT_CA_KEY} (prime256v1 EC key)..."
        openssl ecparam -out "${ROOT_CA_KEY}" -name prime256v1 -genkey || log_error "Failed to generate Root CA private key."
        chmod 600 "${ROOT_CA_KEY}" # Secure private key
        log_success "Root CA private key created."
    else
        log_info "Root CA private key already exists: ${ROOT_CA_KEY}"
    fi

    log_info "Validating Root CA private key..."
    openssl ec -text -noout -check -in "${ROOT_CA_KEY}" || log_error "Root CA private key validation failed."
    log_success "Root CA private key validated."
}

function generate_root_ca_certificate() {
    log_header "Generating Root CA Certificate (Self-Signed)"
    if [ ! -f "${ROOT_CA_CRT}" ]; then
        log_info "Creating ${ROOT_CA_CRT} from ${ROOT_CA_KEY}..."
        # Using -config and -extensions v3_ca as defined in openssl.cnf for a self-signed CA cert.
        # Removed -extfile "${WORKDIR}/csr/csr.conf" as -extfile is not for openssl req -x509 (as per earlier discussion).
        # Extensions are now read directly from openssl.cnf's [v3_ca] via x509_extensions = v3_ca in [req].
        openssl req -x509 -new -nodes -key "${ROOT_CA_KEY}" \
            -out "${ROOT_CA_CRT}" -config "${OPENSSL_CONFIG}" \
            -extensions v3_ca -days 3650 || log_error "Failed to generate Root CA certificate."
        log_success "Root CA certificate created."
    else
        log_info "Root CA certificate already exists: ${ROOT_CA_CRT}"
    fi

    log_info "Displaying Root CA certificate details..."
    openssl x509 -in "${ROOT_CA_CRT}" -text -noout || log_error "Failed to display Root CA certificate details."
}

function generate_intermediate_ca() {
    log_header "Generating Intermediate CA Key and Certificate"

    # Generate Intermediate CA Private Key
    if [ ! -f "${INTERMEDIATE_CA_KEY}" ]; then
        log_info "Creating ${INTERMEDIATE_CA_KEY} (prime256v1 EC key)..."
        openssl ecparam -out "${INTERMEDIATE_CA_KEY}" -name prime256v1 -genkey || log_error "Failed to generate Intermediate CA private key."
        chmod 600 "${INTERMEDIATE_CA_KEY}" # Secure private key
        log_success "Intermediate CA private key created."
    else
        log_info "Intermediate CA private key already exists: ${INTERMEDIATE_CA_KEY}"
    fi

    # Generate Intermediate CA CSR
    log_info "Creating Intermediate CA CSR: ${INTERMEDIATE_CA_CSR}..."
    # The -extensions v3_ca is specified in openssl.cnf for req_extensions, so no need here.
    openssl req -new -key "${INTERMEDIATE_CA_KEY}" \
        -out "${INTERMEDIATE_CA_CSR}" -config "${OPENSSL_CONFIG}" ||
        log_error "Failed to generate Intermediate CA CSR."
    log_success "Intermediate CA CSR created."

    # Sign Intermediate CA Certificate with Root CA
    log_info "Signing Intermediate CA certificate with Root CA: ${INTERMEDIATE_CA_CRT}..."
    # Use 'openssl ca' for proper CA operations (index.txt, serial management)
    # The extensions are taken from the [v3_ca] section in openssl.cnf via 'x509_extensions = v3_ca' in [CA_default]
    openssl ca -batch -config "${OPENSSL_CONFIG}" \
        -in "${INTERMEDIATE_CA_CSR}" -out "${INTERMEDIATE_CA_CRT}" \
        -days 1825 -notext -md sha256 -extensions v3_ca || log_error "Failed to sign Intermediate CA certificate." # 5 years validity
    log_success "Intermediate CA certificate signed and created."

    log_info "Displaying Intermediate CA certificate details..."
    openssl x509 -in "${INTERMEDIATE_CA_CRT}" -text -noout || log_error "Failed to display Intermediate CA certificate details."
}

function generate_machine_certs() {
    log_header "Generating Machine Certificates (Keys, CSRs, and Signing)"

    for MY_HOST in "${!DEB_HOSTS[@]}"; do
        local HOST_IP="${DEB_HOSTS[${MY_HOST}]}"
        local HOST_KEY="${WORKDIR}/private/${MY_HOST}.key"
        local HOST_CSR="${WORKDIR}/csr/${MY_HOST}.csr"
        local HOST_CRT="${WORKDIR}/certs/${MY_HOST}.crt"
        local HOST_CHAIN_PEM="${WORKDIR}/certs/${MY_HOST}-chain.pem"
        local HOST_CSR_CONF="${WORKDIR}/csr/${MY_HOST}.csr.conf" # Temporary config for specific host

        log_info "--- Processing host: ${MY_HOST} (IP: ${HOST_IP}) ---"

        # Generate Private Key for Host
        if [ ! -f "${HOST_KEY}" ]; then
            log_info "Creating private key for ${MY_HOST}: ${HOST_KEY} (prime256v1 EC key)..."
            openssl ecparam -out "${HOST_KEY}" -name prime256v1 -genkey || log_error "Failed to generate key for ${MY_HOST}."
            chmod 600 "${HOST_KEY}" # Secure private key
            log_success "Private key for ${MY_HOST} created."
        else
            log_info "Private key for ${MY_HOST} already exists: ${HOST_KEY}"
        fi

        # Generate Host-Specific CSR Configuration
        log_info "Creating host-specific CSR configuration for ${MY_HOST}: ${HOST_CSR_CONF}..."
        cat >"${HOST_CSR_CONF}" <<EOF
[ req ]
default_bits = 4096 # Use the same bit strength as req section or specify
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
C = US
ST = Colorado
L = Denver
O = Bitsmasher Labs
OU = lab
CN = ${MY_HOST}.lab.bitsmasher.net/emailAddress=franklin@bitsmasher.net

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = ${MY_HOST}
DNS.2 = ${MY_HOST}.lab.bitsmasher.net
IP.1 = ${HOST_IP}
EOF
        log_success "Host-specific CSR config created."

        # Generate CSR for Host
        log_info "Generating CSR for ${MY_HOST}: ${HOST_CSR}..."
        # Using the specific config for this host for SANs and DN.
        # This overrides the global [req] and [alt_names] in openssl.cnf for this specific CSR.
        openssl req -new -key "${HOST_KEY}" \
            -out "${HOST_CSR}" -config "${HOST_CSR_CONF}" \
            -sha256 || log_error "Failed to generate CSR for ${MY_HOST}."
        log_success "CSR for ${MY_HOST} created."

        # Sign Host Certificate using Intermediate CA
        log_info "Signing certificate for ${MY_HOST} with Intermediate CA: ${HOST_CRT}..."
        # This uses the [CA_default] section from openssl.cnf and its configured
        # x509_extensions (usr_cert). The SANs come from the CSR itself.
        openssl ca -batch -config "${OPENSSL_CONFIG}" \
            -in "${HOST_CSR}" -out "${HOST_CRT}" \
            -days 365 -notext -md sha256 -extensions usr_cert || log_error "Failed to sign certificate for ${MY_HOST}."
        log_success "Certificate for ${MY_HOST} signed and created."

        # Display Certificate Details
        log_info "Displaying certificate details for ${MY_HOST}..."
        openssl x509 -in "${HOST_CRT}" -text -noout || log_error "Failed to display certificate details for ${MY_HOST}."

        # Create Certificate Chain
        log_info "Creating certificate chain for ${MY_HOST}: ${HOST_CHAIN_PEM}..."
        cat "${HOST_CRT}" "${INTERMEDIATE_CA_CRT}" "${ROOT_CA_CRT}" >"${HOST_CHAIN_PEM}" || log_error "Failed to create chain for ${MY_HOST}."
        log_success "Certificate chain for ${MY_HOST} created."

        # Copy Root CA to System Trust Store (requires sudo)
        log_info "Copying Root CA to system trust store for ${MY_HOST}..."
        # This step is critical for systems to trust your certificates.
        sudo cp "${ROOT_CA_CRT}" "/usr/local/share/ca-certificates/bitsmasher-root-ca.crt" || log_error "Failed to copy root CA to system trust store."
        sudo update-ca-certificates || log_error "Failed to update system CA certificates."
        log_success "Root CA added to system trust."
    done
    
}

function validate_pki_components() {
    log_header "Validating PKI Components"

    # Validate Root CA Key and Certificate Match
    log_info "Checking if Root CA Private Key and Certificate match..."
    local ROOT_MOD_PUB=$(openssl x509 -in "${ROOT_CA_CRT}" -noout -modulus | openssl md5)
    local ROOT_MOD_PRIV=$(openssl ec -in "${ROOT_CA_KEY}" -noout -modulus | openssl md5) # Use 'ec' for EC keys
    if [ "${ROOT_MOD_PRIV}" != "${ROOT_MOD_PUB}" ]; then
        log_error "Root CA Key/Certificate mismatch! Public and private key moduli do NOT match."
    fi
    log_success "Root CA Key and Certificate match confirmed."

    # Validate Intermediate CA Key and CSR Match
    log_info "Checking if Intermediate CA Private Key and CSR match..."
    local INTER_MOD_PUB_CSR=$(openssl req -in "${INTERMEDIATE_CA_CSR}" -noout -modulus | openssl md5)
    local INTER_MOD_PRIV_KEY=$(openssl ec -in "${INTERMEDIATE_CA_KEY}" -noout -modulus | openssl md5)
    if [ "${INTER_MOD_PRIV_KEY}" != "${INTER_MOD_PUB_CSR}" ]; then
        log_error "Intermediate CA Key/CSR mismatch! Public key in CSR and private key moduli do NOT match."
    fi
    log_success "Intermediate CA Key and CSR match confirmed."

    # Validate Intermediate CA Certificate Chain (signed by Root CA)
    log_info "Verifying Intermediate CA certificate against Root CA..."
    openssl verify -CAfile "${ROOT_CA_CRT}" "${INTERMEDIATE_CA_CRT}" || log_error "Intermediate CA certificate verification failed against Root CA."
    log_success "Intermediate CA certificate verified by Root CA."

    # Validate a sample Machine Certificate (e.g., 'time') against its chain
    local SAMPLE_HOST="time"
    if [[ " ${!DEB_HOSTS[@]} " =~ " ${SAMPLE_HOST} " ]]; then # Check if sample host exists in array
        local SAMPLE_HOST_CRT="${WORKDIR}/certs/${SAMPLE_HOST}.crt"
        local SAMPLE_HOST_CHAIN="${WORKDIR}/certs/${SAMPLE_HOST}-chain.pem"
        log_info "Validating sample machine certificate (${SAMPLE_HOST}) against its chain..."
        if [ -f "${SAMPLE_HOST_CHAIN}" ]; then
            # Verify against the full chain (server.crt + intermediate.crt + root.crt)
            # The verify command usually needs individual -untrusted for intermediates or all in -CAfile.
            # Using the system trust store (where root CA was copied) is often more realistic.
            openssl verify "${SAMPLE_HOST_CRT}" || log_error "Sample machine certificate validation failed against system trust store."
            # Or explicitly using the chain:
            # openssl verify -CAfile "${ROOT_CA_CRT}" -untrusted "${INTERMEDIATE_CA_CRT}" "${SAMPLE_HOST_CRT}" || log_error "Sample machine certificate validation failed against explicit chain."
            log_success "Sample machine certificate verified successfully."
        else
            log_error "Sample host chain file not found: ${SAMPLE_HOST_CHAIN}. Cannot perform full chain validation."
        fi

        # Validate Sample Machine Certificate Key and CSR Match
        log_info "Checking if ${SAMPLE_HOST} Private Key and CSR match..."
        local HOST_CSR="${WORKDIR}/csr/${SAMPLE_HOST}.csr"
        local HOST_KEY="${WORKDIR}/private/${SAMPLE_HOST}.key"
        local HOST_MOD_PUB_CSR=$(openssl req -in "${HOST_CSR}" -noout -modulus | openssl md5)
        local HOST_MOD_PRIV_KEY=$(openssl ec -in "${HOST_KEY}" -noout -modulus | openssl md5)
        if [ "${HOST_MOD_PRIV_KEY}" != "${HOST_MOD_PUB_CSR}" ]; then
            log_error "${SAMPLE_HOST} Key/CSR mismatch! Public key in CSR and private key moduli do NOT match."
        fi
        log_success "${SAMPLE_HOST} Key and CSR match confirmed."
    else
        log_error "Sample host '${SAMPLE_HOST}' not found in DEB_HOSTS array. Skipping detailed machine cert validation."
    fi

    log_success "All specified PKI components validated."
}

# --- Main Execution Flow ---
function main() {
    log_header "Starting PKI Setup Script"

    # Ensure we are in the WORKDIR for relative paths used by openssl config
    # The config uses $dir internally, so 'cd' is good.
    create_pki_structure
    pushd "${WORKDIR}" >/dev/null || log_error "Failed to change directory to ${WORKDIR}."

    generate_root_ca_key
    generate_root_ca_certificate
    generate_intermediate_ca
    generate_machine_certs

    # Pop back to original directory after all operations in WORKDIR
    popd >/dev/null || log_error "Failed to return to original directory."

    #validate_pki_components

    log_header "PKI Setup Script Completed Successfully!"
}

main "$@"
