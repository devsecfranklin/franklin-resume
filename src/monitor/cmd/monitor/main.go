package main

import (
	"fmt"
	"net"
	"log"
	"os"

	mpi "github.com/mnlphlp/gompi" // Import the gompi library
	"os/exec"
)

func check_openmpi() {
	// Execute the ompi_info command
	cmd := exec.Command("ompi_info")
	output, err := cmd.CombinedOutput()

	// Check if the command executed successfully
	if err != nil {
		fmt.Println("Error executing ompi_info:", err)
		fmt.Println("OpenMPI may not be installed or not in your PATH.")
		return
	}

	// If no error, OpenMPI is likely installed
	fmt.Println("OpenMPI is installed.")
	fmt.Println("ompi_info output:")
	fmt.Println(string(output))
}

func check_ip() {
	_, network, err := net.ParseCIDR("10.10.8.0/21")
	if err != nil {
		fmt.Println("Error parsing CIDR:", err)
		return
	}

	ip := net.ParseIP("10.10.8.1")
	if ip == nil {
		fmt.Println("Error parsing IP address")
		return
	}

	if network.Contains(ip) {
		fmt.Println(ip, "is in subnet", network)
	} else {
		fmt.Println(ip, "is not in subnet", network)
	}
}

func main() {
	check_openmpi() // make sure it is installed

	// Initialize the MPI environment
	// This must be the first MPI call in your program.
	mpi.Init()

	// Ensure MPI is finalized when the program exits.
	// This cleans up the MPI environment.
	defer mpi.Finalize()

	// Get the MPI_COMM_WORLD communicator.
	// MPI_COMM_WORLD is the default communicator that includes all processes.
	comm := mpi.NewComm(false) // 'false' means don't panic on MPI errors, return error code instead

	// Get the rank of the current process within the communicator.
	// The rank is a unique integer ID for each process, from 0 to size-1.
	rank := comm.GetRank() 

	// Get the total number of processes in the communicator.
	size := comm.GetSize()

	// Get the hostname of the node the current process is running on.
	// This is a standard Go function, not an MPI-specific call.
	hostname, err := os.Hostname()
	if err!= nil {
		log.Printf("Error getting hostname for rank %d: %v", rank, err)
		hostname = "unknown"
	}

	// Print the identification information for each process.
	// Each process will execute this line independently.
	fmt.Printf("Hello from MPI process %d of %d on node: %s\n", rank, size, hostname)
}
