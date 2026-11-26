import threading
import time
import unittest
class TestCpuModeFiltering(unittest.TestCase):
        def idle_worker():
            try:
                time.sleep(5)
            except Exception:
                return
        def cpu_active_worker():
            end = time.time() + 0.1
            x = 0
            while time.time() < end:
                x += 1
        cpu_thread = threading.Thread(target=cpu_active_worker, name="cpu_active_worker", daemon=True)
        cpu_thread.start()
        self.assertIn('idle_worker', wall_mode_output)
if __name__ == "__main__":
    unittest.main()
