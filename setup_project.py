import os

# --- Configuration: Define the 'dashsocial' project structure ---
# This dictionary represents the folder structure inside the 'lib' directory.
project_structure = {
    "controllers": [
        "auth_controller.dart",
        "home_controller.dart",
        "dashboard_controller.dart",
        "profile_controller.dart"
    ],
    "models": [
        "user_model.dart",
        "post_model.dart",
        "stats_model.dart"
    ],
    "presentation": {
        "screens": [
            "auth_screen.dart",
            "home_screen.dart",
            "dashboard_screen.dart",
            "profile_screen.dart"
        ],
        "widgets": [
            "custom_app_bar.dart",
            "post_card.dart",
            "loading_spinner.dart"
        ]
    },
    "services": [
        "supabase_service.dart",
        "cloudinary_service.dart",
        "api_handler.dart"
    ],
    "utils": [
        "constants.dart",
        "app_theme.dart",
        "helpers.dart"
    ]
}

def create_project_structure(base_path, structure):
    """
    Recursively creates folders and files based on the provided structure.

    :param base_path: The starting path to create the structure in.
    :param structure: A dictionary or list representing the structure.
    """
    # Ensure the base path itself exists
    if not os.path.exists(base_path):
        os.makedirs(base_path)
        print(f"Created Base Directory: {base_path}")

    if isinstance(structure, dict):
        # If it's a dictionary, iterate through its items (folder/sub-structure)
        for name, content in structure.items():
            current_path = os.path.join(base_path, name)
            # Create the directory if it doesn't exist
            if not os.path.exists(current_path):
                os.makedirs(current_path)
                print(f"Created Directory: {current_path}")
            # Recurse into the sub-structure
            create_project_structure(current_path, content)
    elif isinstance(structure, list):
        # If it's a list, it contains file names
        for filename in structure:
            file_path = os.path.join(base_path, filename)
            # Create an empty file if it doesn't exist
            if not os.path.exists(file_path):
                with open(file_path, 'w') as f:
                    # Add a comment to the new file
                    f.write(f"// {filename} created by setup script for DashSocial\n")
                print(f"  - Created File: {file_path}")

# --- Main execution ---
if __name__ == "__main__":
    # The script should be run from the root of the Flutter project.
    # We will create the structure inside the 'lib' folder.
    lib_path = "lib"

    print("Starting DashSocial project setup...")

    if not os.path.exists(lib_path):
        print(f"Error: '{lib_path}' directory not found.")
        print("Please run this script from the root of your Flutter project.")
    else:
        # Start the recursive creation process
        create_project_structure(lib_path, project_structure)
        print("\nDashSocial project structure created successfully!")
        print("You can now start adding code to the generated files.")

