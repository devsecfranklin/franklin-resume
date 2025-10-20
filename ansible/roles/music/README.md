# music

- [How to Install and Configure VNC on Debian 11](https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-vnc-on-debian-11)
- [MusicBrainz Picard](https://picard.musicbrainz.org/)
- [Echoprint](https://echoprint.tumblr.com/) is a music fingerprint or music
identification service. It listens to music signals and tells you what song is
playing. It’s backed by a huge database of music that grows with the community
and further partnerships.
  - [I want to deduplicate a big collection](https://echoprint.tumblr.com/start#deduplicate)

## Requirements

Any pre-requisites that may not be covered by Ansible itself or the role should be mentioned here. For instance, if the role uses the EC2 module, it may be a good idea to mention in this section that the boto package is required.

## Role Variables

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

## Dependencies

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

- Python3 - librosa
- remmina
- detox

## Example Playbook

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

## License

BSD

## Author Information

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
