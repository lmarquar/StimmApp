from diagrams import Diagram, Node, Edge

with Diagram("Profile Settings Flow", show=False, filename="profile_settings_flow", direction="TB"):
    start = Node("Start")
    open_settings = Node("Open Profile Settings")
    show_data = Node("Show current profile data")
    stop = Node("Stop")

    # Main flow
    start >> open_settings >> show_data

    # Edit Profile
    edit_flow = Node("Edit fields -> Validate -> Save -> show success/error")
    show_data >> Edge(label="Edit name / state / address?") >> edit_flow >> stop

    # Change Password
    password_flow = Node("Enter current, new, confirm -> call auth -> success? -> show result")
    show_data >> Edge(label="Change password?") >> password_flow >> stop

    # Update Profile Picture
    choose_source = Node("Choose source (Camera / Gallery)")
    open_camera = Node("Open camera -> capture -> proceed")
    open_gallery = Node("Open gallery -> pick -> proceed")
    open_cropper = Node("Open cropper -> confirm")
    upload = Node("Upload -> success?")
    upload_success = Node("Update profile picture -> show success")
    upload_failure = Node("Show failedToUploadImage -> retry / remove")

    show_data >> Edge(label="Update profile picture?") >> choose_source
    choose_source >> Edge(label="Camera") >> open_camera
    choose_source >> Edge(label="Gallery") >> open_gallery
    open_camera >> open_cropper
    open_gallery >> open_cropper
    open_cropper >> upload
    upload >> Edge(label="yes") >> upload_success >> stop
    upload >> Edge(label="no") >> upload_failure >> stop
