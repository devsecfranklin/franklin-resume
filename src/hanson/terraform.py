import logging
import sys
from pathlib import Path

from python_terraform import Terraform

logger = logging.getLogger("hanson")


class TerraformHelpers:
    """ """

    t = Terraform(terraform_bin_path="/usr/bin/terraform")
    lock_file = ".terraform.lock.hcl"
    state_file = ".terraform/terraform.tfstate"

    def check_init(self, path):
        """See if we are ready.

        - Check for presence of .terrafom.lock.hcl
        - Try a `terraform validate`, should return str("Success! The configuration is valid.")
        """
        lock_path = Path(self.lock_file)
        state_path = Path(self.state_file)

        ready = False

        if not lock_path.is_file() and not state_path.is_file():
            print("missing Terraform lockfile or state file")
            logger.debug("missing Terraform lockfile or state file")
            self.t.working_dir = path
            return_code, stdout, stderr = self.t.init()  # missing .terraform.lock.hcl
            if stderr:
                print(stderr)
                logger.debug(stderr)
                return ready
            else:
                print(stdout)
                logger.debug(stdout)
            print("Return code: {} ".format(return_code))

        return_code, stdout, stderr = self.t.validate(capture_output=True)
        if stderr:
            print(stderr)
            logger.debug(stderr)
            return ready
        else:
            print(stdout)
            logger.debug(stdout)
            ready = True
        print("Return code: {} ".format(return_code))

        return ready

    def collect_digraph_from_terraform(self, path):
        """Terraform can output a directed graph.

        Command line examples for png and svg format
        # terraform graph | dot -Tpng > graph.png
        # terraform graph | dot -Tsvg -o graph.svg
        """
        self.t.working_dir = path
        return_code, stdout, stderr = self.t.graph(capture_output=True)
        if stderr:
            print(stderr)
            logger.debug(stderr)
        else:
            print("Return code: {} ".format(return_code))
            logger.debug("Digraph captured: {}".format(stdout))
        return stdout


"""
__author__     = 'Franklin'
__version__    = '0.2'
__email__      = 'devsecfranklin@duck.com'
"""
