#include "krb5_franklin.h"

gss_name_t get_spn(char *spn)
{
    OM_uint32 maj_stat;
    OM_uint32 min_stat;
    gss_buffer_desc name_buf = GSS_C_EMPTY_BUFFER;
    gss_name_t spn_gss_name = GSS_C_NO_NAME;

    name_buf.value = spn;
    name_buf.length = strlen(name_buf.value);

    maj_stat = gss_import_name(&min_stat, &name_buf, GSS_KRB5_NT_PRINCIPAL_NAME, &spn_gss_name);

    if (GSS_ERROR(maj_stat))
    {
        display_status("Major status", maj_stat, GSS_C_GSS_CODE);
        display_status("Minor status", min_stat, GSS_C_MECH_CODE);
    }

    return spn_gss_name;
}

char* init_sec_context(char *spn)
{
    OM_uint32 maj_stat;
    OM_uint32 min_stat;
    OM_uint32 flags = GSS_C_REPLAY_FLAG | GSS_C_SEQUENCE_FLAG | GSS_C_MUTUAL_FLAG;
    gss_ctx_id_t gss_context = GSS_C_NO_CONTEXT;
    gss_name_t spn_gss_name = get_spn(spn);
    gss_buffer_desc output_token;
    char *base64_encoded_kerberos_token = NULL;
    maj_stat = gss_init_sec_context( //
            &min_stat, // minor_status
            GSS_C_NO_CREDENTIAL, // claimant_cred_handle
            &gss_context, // context_handle
            spn_gss_name, // target_name
            GSS_C_NO_OID, // mech_type of the desired mechanism
            flags, // req_flags
            0, // time_req for the context to remain valid. 0 for default lifetime.
            GSS_C_NO_CHANNEL_BINDINGS, // channel bindings
            GSS_C_NO_BUFFER, // input token
            NULL, // actual_mech_type
            &output_token, // output token
            NULL, // ret_flags
            NULL // time_req
            );
    if (GSS_ERROR(maj_stat))
    {
        ...
    }
    else if (output_token.length != 0)
    {
        base64_encoded_kerberos_token = base64_encode(output_token.value, output_token.length, &(output_token.length));
    }

    if (gss_context != GSS_C_NO_CONTEXT)
    {
        gss_delete_sec_context(&min_stat, &gss_context, GSS_C_NO_BUFFER);
    }
    if (spn_gss_name != GSS_C_NO_NAME)
    {
        gss_release_name(&min_stat, &spn_gss_name);
    }
    gss_release_buffer(&min_stat, &output_token);

    return base64_encoded_kerberos_token;
}
