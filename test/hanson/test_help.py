import unittest

class TestMyHelpMethods(unittest.TestCase):

    def test_send_bot_help(self):
        self.assertEqual('foo'.upper(), 'FOO')

    def test_send_command_help(self):
        self.assertTrue('FOO'.isupper())
        self.assertFalse('Foo'.isupper())

    def test_send_group_help(self):
        s = 'hello world'
        self.assertEqual(s.split(), ['hello', 'world'])
        # check that s.split fails when the separator is not a string
        with self.assertRaises(TypeError):
            s.split(2)

    def test_send_cog_help(self):

    def test_send_error_message(self):


if __name__ == '__main__':
    unittest.main()
