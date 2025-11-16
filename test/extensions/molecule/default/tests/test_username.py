import pytest


@pytest.mark.parametrize('username', [
    'test_usr1',
    'test_usr2',
    'test_usr5',
])
def test_oh_my_zsh_install(host, username):
    oh_my_zsh = host.file('/home/' + username + '/.oh-my-zsh')
    assert oh_my_zsh.exists
    assert oh_my_zsh.is_directory
    assert oh_my_zsh.user == username
    assert oh_my_zsh.group in [username, 'users']