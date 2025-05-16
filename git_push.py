import os
import subprocess
import sys

# ANSI escape codes for bold and blue
BLUE = "\033[0;34m"
RESET = "\033[0m"

# Emoji
EMOJI = "🌿"

# ANSI escape code for red bold text
RED_BOLD = "\033[1;31m"

# Caution/Warning Emoji
WARNING_EMOJI = "🚨"

def print_message(message):
    """Prints a styled message with emoji."""
    print(f"{EMOJI} {BLUE}{message}{RESET}")

def run_command(command, error_message):
    """Run a shell command and exit on failure."""
    try:
        subprocess.run(command, check=True, shell=True)
    except subprocess.CalledProcessError:
        print_message(f"Error: {error_message}")
        sys.exit(1)

def ensure_git_repository():
    """Ensure the current directory is a Git repository."""
    try:
        subprocess.run("git rev-parse --is-inside-work-tree", check=True, shell=True, stdout=subprocess.DEVNULL)
    except subprocess.CalledProcessError:
        print_message("This directory is not a Git repository.")
        sys.exit(1)

def get_current_branch():
    """Retrieve the current branch name."""
    result = subprocess.run("git rev-parse --abbrev-ref HEAD", shell=True, capture_output=True, text=True)
    return result.stdout.strip()

def list_remotes():
    """List all unique remotes for the repository."""
    result = subprocess.run("git remote", shell=True, capture_output=True, text=True)
    remotes = result.stdout.strip().split("\n")
    return [(remote, None) for remote in remotes]

def git_operations():
    """Perform Git operations: stage, commit, and push to all remotes."""
    print_message("Staging changes...")
    run_command("git add -A", "Failed to stage changes")

    # Check if there are staged changes
    staged_result = subprocess.run("git diff --cached --quiet", shell=True)
    if staged_result.returncode == 0:
        print_message("No changes to commit. Working tree is clean.")
        return

    # Get commit message
    try:
        commit_message = input(f"{EMOJI} {BLUE}Enter commit message (leave blank for default: 'Update'):{RESET} ").strip() or "Update"
    except KeyboardInterrupt:
        print()
        print_message("Process interrupted. Exiting cleanly.")
        sys.exit(0)

    print_message("Committing changes...")
    run_command(f"git commit -m '{commit_message}'", "Failed to commit changes")
    print_message(f"Changes committed with message: '{commit_message}'.")

    # Get current branch
    current_branch = get_current_branch()
    print_message(f"Current branch: {BLUE}{current_branch}{RESET}")

    # Confirmation warning before pushing
    try:
        print(f"{WARNING_EMOJI} {RED_BOLD}Warning: You are about to push to the '{current_branch}' branch for all remotes. Continue? (y/N): {RESET}", end="")
        confirm_push = input().strip().lower()
        if confirm_push != "y":
            print()
            print_message("Push operation canceled. Exiting cleanly.")
            sys.exit(0)
    except KeyboardInterrupt:
        print()
        print_message("Process interrupted. Exiting cleanly.")
        sys.exit(0)

    # List all remotes
    remotes = list_remotes()
    if not remotes:
        print_message("No remotes found. Please add a remote before pushing.")
        sys.exit(1)

    # Push to all remotes
    for remote, _ in remotes:
        print_message(f"Pushing branch '{current_branch}' to remote '{remote}'...")
        
        remote_branch_exists = subprocess.run(
            f"git ls-remote --heads {remote} {current_branch}",
            shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE
        )

        if remote_branch_exists.returncode != 0 or not remote_branch_exists.stdout:
            print_message(f"Branch '{current_branch}' does not exist on '{remote}'. Creating it...")
            run_command(f"git push -u {remote} {current_branch}", f"Failed to push '{current_branch}' to '{remote}'.")
        else:
            print_message(f"Branch '{current_branch}' exists on '{remote}'. Pushing changes...")
            run_command(f"git push {remote} {current_branch}", f"Failed to push '{current_branch}' to '{remote}'.")

    print_message(f"Successfully pushed branch '{current_branch}' to all remotes.")

def main():
    ensure_git_repository()
    git_operations()
    print_message("Displaying git status...")
    run_command("git status", "Failed to display git status")

if __name__ == "__main__":
    main()
