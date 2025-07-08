import os

# --- Configuration ---
# Markers in the README where the project list will be injected.
START_MARKER = "<!--START_PROJECTS_LIST-->"
END_MARKER = "<!--END_PROJECTS_LIST-->"

# List of directories to ignore when scanning for projects.
IGNORE_LIST = ['.git', '.github', 'assets']


def get_project_folders():
    """
    Scans the current directory for sub-folders that are considered projects.
    Returns a sorted list of project folder names.
    """
    print("Scanning for project folders...")
    try:
        # List all items in the current directory.
        all_items = os.listdir('.')
        # Filter for items that are directories and are not in the IGNORE_LIST.
        project_folders = [
            item for item in all_items
            if os.path.isdir(item) and item not in IGNORE_LIST
        ]
        project_folders.sort()
        print(f"✅ Found projects: {project_folders}")
        return project_folders
    except Exception as e:
        print(f"❌ Error scanning for folders: {e}")
        return []


def format_projects_as_markdown(folders):
    """
    Takes a list of folder names and formats it into a Markdown bulleted list.
    It attempts to read the first line of each project's README for a description.
    """
    if not folders:
        return "No projects found in this repository yet."

    markdown_list = []
    for folder in folders:
        # Create a more readable name from the folder name.
        project_name = folder.replace('_', ' ').replace('-', ' ').title()
        project_url = f"./{folder}/"
        description = ""

        # Try to get a description from the project's own README.md.
        try:
            readme_path = os.path.join(folder, 'README.md')
            if os.path.exists(readme_path):
                with open(readme_path, 'r', encoding='utf-8') as f:
                    # Read the first few lines to find a description.
                    for line in f:
                        # Skip titles and empty lines.
                        if line.strip() and not line.strip().startswith('#'):
                            description = line.strip()
                            break # Use the first non-title, non-empty line.
        except Exception:
            # If reading fails, just proceed without a description.
            pass
        
        # Append the formatted line to our list.
        if description:
            markdown_list.append(f"* **[{project_name}]({project_url})**: {description}")
        else:
            markdown_list.append(f"* **[{project_name}]({project_url})**")

    return "\n".join(markdown_list)


def update_readme(project_list_md):
    """
    Reads the main README.md file, finds the start and end markers,
    and injects the formatted list of projects between them.
    """
    try:
        with open("README.md", "r", encoding="utf-8") as f:
            readme_content = f.read()

        # Find the exact positions of our markers in the file content.
        start_index = readme_content.find(START_MARKER)
        end_index = readme_content.find(END_MARKER)

        if start_index == -1 or end_index == -1:
            print("❌ Markers not found in README.md. Please add them.")
            return

        # Reconstruct the file content with the new list.
        new_readme = (
            readme_content[:start_index + len(START_MARKER)] +
            "\n\n" +
            project_list_md +
            "\n\n" +
            readme_content[end_index:]
        )

        # Write the newly constructed content back to the README.md file.
        with open("README.md", "w", encoding="utf-8") as f:
            f.write(new_readme)
        
        print("✅ README.md updated successfully!")

    except FileNotFoundError:
        print("❌ README.md file not found in the current directory.")


# --- Main Execution ---
# This block runs only when the script is executed directly.
if __name__ == "__main__":
    project_folders = get_project_folders()
    project_list_markdown = format_projects_as_markdown(project_folders)
    update_readme(project_list_markdown)
