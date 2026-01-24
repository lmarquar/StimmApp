from diagrams import Diagram, Node, Edge
from diagrams.custom import Custom

# Define some styles
graph_attr = {
    "fontsize": "16",
    "bgcolor": "white",
    "ranksep": "0.5",
    "nodesep": "0.5",
}

node_attr = {
    "fontsize": "12",
    "fontname": "Arial",
}

with Diagram("Profile Settings Flow", show=False, filename="profile_settings_flow", direction="TB", graph_attr=graph_attr, node_attr=node_attr):
    start = Node("Start", shape="Mdiamond", color="green", style="filled", fillcolor="lightgreen")
    open_settings = Node("Open Profile Settings")
    show_data = Node("Show current profile data", shape="box", style="rounded,filled", fillcolor="lightblue")
    stop = Node("Stop", shape="Mdiamond", color="red", style="filled", fillcolor="lightpink")

    # Main flow
    start >> open_settings >> show_data

    # Edit Profile
    edit_flow = Node("Edit fields\nValidate\nSave", shape="component")
    show_data >> Edge(label="Edit name / state / address?") >> edit_flow >> stop

    # Change Password
    password_flow = Node("Enter current, new, confirm\nCall Auth\nShow Result", shape="component")
    show_data >> Edge(label="Change password?") >> password_flow >> stop

    # Update Profile Picture
    choose_source = Node("Choose source\n(Camera / Gallery)", shape="diamond")
    open_camera = Node("Open camera\nCapture", shape="box")
    open_gallery = Node("Open gallery\nPick", shape="box")
    open_cropper = Node("Open cropper\nConfirm", shape="box")
    upload = Node("Upload\nSuccess?", shape="diamond")
    upload_success = Node("Update profile picture\nShow success", color="green")
    upload_failure = Node("Show failedToUploadImage\nRetry / Remove", color="red")

    show_data >> Edge(label="Update profile picture?") >> choose_source
    choose_source >> Edge(label="Camera") >> open_camera
    choose_source >> Edge(label="Gallery") >> open_gallery
    open_camera >> open_cropper
    open_gallery >> open_cropper
    open_cropper >> upload
    upload >> Edge(label="yes", color="green") >> upload_success >> stop
    upload >> Edge(label="no", color="red") >> upload_failure >> stop
