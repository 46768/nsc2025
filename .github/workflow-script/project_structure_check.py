import os
import pathlib
import yaml


def get_project_root():
    cwd = os.getcwd()

    while not os.path.exists(cwd+'/.git') and cwd != '/':
        cwd = str(pathlib.Path(cwd, '..').resolve())
    if cwd == '/':
        print("Cant find project root")
        exit(1)
    return cwd


if __name__ == "__main__":
    project_root = get_project_root()
    root_path = pathlib.Path(project_root)
    config_path = pathlib.Path(
            project_root, '.github', 'workflow-config',
            'project-structure.yml')
    if not config_path.exists():
        print("Config path at", str(config_path), "Not found")
        exit(1)

    with config_path.open() as f:
        project_structs = yaml.safe_load(f.read())
    have_err = False

    for dpath, allow_list in project_structs.items():
        target_dir = root_path / dpath
        if not target_dir.exists():
            print("Directory", str(target_dir), "Not exists")
            continue

        files = [x for x in (target_dir).glob('./**') if x.is_file()]
        ftype = set([x.suffix.lstrip('.') for x in files])
        bad_type = ftype - set(allow_list)
        if bad_type:
            bad_file = [
                    str(x) for x in files if
                    x.suffix.lstrip('.') not in allow_list]
            print("bad file type in", dpath, ":", bad_file)
            have_err = True

    if have_err:
        exit(1)
    exit(0)
