import sys
import subprocess

def run_test (command):
    test = subprocess.call(command)
    return test

if __name__ == "__main__":
    pytest = "./pytest_processor.py"
    subprocess_command = [pytest]
    [subprocess_command.append(x) for x in sys.argv[2:]]
    iterations = int(sys.argv[1])

    failures = 0

    print ("Running", ' '.join(subprocess_command), iterations, "times. . .")

    for x in range(0, iterations):
        result = run_test(subprocess_command)
        if result != 0:
            # Exited failure
            print ("Run", x, "failed with code", result)
            failures += 1

    print("Completed", iterations, "runs of", ' '.join(subprocess_command), "results:")
    print("Consistency:", failures, "failures during", iterations, "iterations\n",
            " ==> [", failures/iterations*100, "% Failures]", "\n",
            " ==> [", 100-(failures/iterations*100), "% Success]")
