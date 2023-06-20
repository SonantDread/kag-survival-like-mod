import os

def print_folder_hierarchy(folder_path, level=0):
    for root, dirs, files in os.walk(folder_path):
        indent = "|   " * level
        print(f"{indent}+-- {os.path.basename(root)}/")
        sub_indent = "|   " * (level + 1)
        for file in files:
            print(f"{sub_indent}+-- {file}")

def find_includes(folder_path, extensions, target_files, level=0):
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            if file.endswith(extensions) and file in target_files:
                file_path = os.path.join(root, file)
                with open(file_path) as f:
                    for line in f:
                        if line.startswith("#include"):
                            include_path = line.split('"')[1]
                            new_target_files = [include_path]
                            include_path_found = False
                            for r, d, f in os.walk(os.path.dirname(file_path)):
                                if include_path in f:
                                    include_path_found = True
                                    break
                            if include_path_found:
                                include_path_root = os.path.join(os.path.dirname(file_path), os.path.dirname(include_path))
                                print_folder_hierarchy(include_path_root, level + 1)
                                with open(os.path.join(include_path_root, os.path.basename(include_path))) as inc_f:
                                    for inc_line in inc_f:
                                        if inc_line.startswith("#include"):
                                            inc_include_path = inc_line.split('"')[1]
                                            if inc_include_path.endswith(extensions):
                                                inc_include_path_found = False
                                                for r, d, f in os.walk(include_path_root):
                                                    if inc_include_path in f:
                                                        inc_include_path_found = True
                                                        break
                                                if inc_include_path_found:
                                                    print_folder_hierarchy(os.path.join(include_path_root, os.path.dirname(inc_include_path)), level + 2)
                                                    indent = "|   " * level + "+-- "
                                                    print(indent + os.path.basename(root) + "/" + file + " (includes) " + os.path.join(os.path.dirname(include_path), os.path.basename(inc_include_path)))
                                find_includes(include_path_root, extensions, new_target_files, level + 3)

# example usage
folder_path = r"C:\Program Files (x86)\Steam\steamapps\common\King Arthur's Gold\Base"
extensions = (".as",)
target_files = [
                "AnimalRiding.as",
                "Seats.as",
                "Shark.as",
                "GibIntoSteaks.as",
                "FleshHitEffects.as",
                "FleshHit.as",
                "AquaticAnimal.as",
                "RegenHealth.as",
                "EatOthers.as"
                ]
find_includes(folder_path, extensions, target_files)
