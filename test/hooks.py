#!/usr/bin/env python3
"""Interactive PTY tests; never send keys to a desktop terminal."""
import os, pty, select, subprocess, time, unittest, pathlib, tempfile

ROOT = pathlib.Path(__file__).resolve().parents[1]


class HooksTests(unittest.TestCase):
    def run_shell(self, shell, source):
        master, slave = pty.openpty()
        env = {**os.environ, "TERM": "xterm", "SHELL_IME_BACKEND": "vscode"}
        env.pop("TMUX", None)
        env.pop("STY", None)
        with tempfile.TemporaryDirectory() as state:
            env["SHELL_IME_STATE_DIR"] = state
            process = subprocess.Popen(
                shell, stdin=slave, stdout=slave, stderr=slave, env=env, close_fds=True
            )
            os.close(slave)

            def read():
                data = b""
                deadline = time.monotonic() + 1
                while time.monotonic() < deadline:
                    if select.select([master], [], [], 0.1)[0]:
                        try:
                            data += os.read(master, 65536)
                        except OSError:
                            break
                return data

            try:
                read()
                os.write(
                    master, ("source " + str(ROOT / "shell" / source) + "\n").encode()
                )
                read()
                for command, expected in [
                    ("ime status", "english"),
                    ("ime system; ime status", "system"),
                    ("ime english; ime status", "english"),
                ]:
                    os.write(master, (command + "\n").encode())
                    output = read()
                    self.assertIn((expected + "\r\n").encode(), output)
                os.write(
                    master,
                    ("source " + str(ROOT / "shell" / source) + "; false\n").encode(),
                )
                read()
                os.write(master, b'printf "RC=%s\\n" "$?"\n')
                self.assertIn(b"RC=1", read())
                os.write(master, b"read shell_ime_test\n")
                out = read()
                self.assertIn(b"\x1b]777;shell-ime;0\x07", out)
                os.write(master, b"hello\n")
                read()
            finally:
                process.kill()
                process.wait(timeout=5)
                os.close(master)

    def test_bash(self):
        self.run_shell(["bash", "--norc", "--noprofile", "-i"], "bash.sh")

    def test_zsh(self):
        self.run_shell(["zsh", "-f", "-i"], "zsh.sh")


if __name__ == "__main__":
    unittest.main()
