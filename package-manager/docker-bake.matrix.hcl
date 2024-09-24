variable build_matrix {
    default = {
        builds = [
            {version = "2024.08.2-9", os = "ubuntu2204", mark_latest = true},
            {version = "2024.08.0-6", os = "ubuntu2204", mark_latest = false},
            {version = "2024.04.4-35", os = "ubuntu2204", mark_latest = false},
            ]
    }
}