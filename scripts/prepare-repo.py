#!/usr/bin/env python3
import argparse
import json
import os
import re
import shutil
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import flake_structure


def nix_string(value):
    text = str(value).replace("${", "''${")
    return json.dumps(text, ensure_ascii=False)


def user_module(username, fullname, hashed_password, shell, version):
    return """/* @menu
   displayname = "Users";
   icon = "avatar-default-symbolic";
   order = 10;
   description = "User Accounts";
   category = "01-Users";
*/

{{ self, inputs, ... }}: {{

  flake.modules.nixos.users = {{ pkgs, ... }}: {{

    imports = [ inputs.home-manager.nixosModules.home-manager ];

    config = {{
      /* @option widget = "users"; label = "Accounts"; homeManager = true; */
      users.users = {{
        {username} = {{
          isNormalUser = true;
          uid = 1000;
          description = {fullname};
          extraGroups = [ "networkmanager" "wheel" "video" "input" ];
          hashedPassword = {hashed_password};
          openssh.authorizedKeys.keys = [ ];
          shell = pkgs.{shell};
        }};
      }};

      home-manager.users = {{
        {username} = {{
          home.stateVersion = "{version}";
        }};
      }};
    }};

  }};

}}
""".format(
        username=username,
        fullname=nix_string(fullname),
        hashed_password=nix_string(hashed_password),
        shell=shell,
        version=version,
    )


def copy_template(template, root, force):
    if not os.path.isdir(template):
        raise RuntimeError("template not found: {}".format(template))

    template_real = os.path.realpath(template)
    root_real = os.path.realpath(root)
    if root_real == template_real or root_real.startswith(template_real + os.sep):
        raise RuntimeError("refusing to copy the template into itself")

    if os.path.exists(root) and os.listdir(root) and not force:
        raise RuntimeError("{} is not empty (pass --force)".format(root))

    os.makedirs(root, exist_ok=True)
    for entry in os.listdir(template):
        if entry == ".git":
            continue
        source = os.path.join(template, entry)
        target = os.path.join(root, entry)
        if os.path.isdir(source) and not os.path.islink(source):
            shutil.copytree(source, target, dirs_exist_ok=True, symlinks=True)
        else:
            shutil.copy2(source, target, follow_symlinks=False)

    for current, directories, files in os.walk(root):
        for name in directories + files:
            path = os.path.join(current, name)
            if not os.path.islink(path):
                os.chmod(path, os.stat(path).st_mode | 0o200)


def configure(args, root):
    interactive = not args.non_interactive
    flake_structure.ensure_configuration(
        root,
        {
            "hostname": args.hostname,
            "state_version": args.state_version,
            "timezone": args.timezone,
            "locale": args.locale,
            "keymap": args.keymap,
            "repo_path": args.clone_relative,
        },
        interactive=interactive,
        choice=args.select,
        fallback_rel="modules/00-configuration.nix",
    )
    flake_structure.ensure_users(
        root,
        user_module(
            args.username,
            args.fullname,
            args.hashed_password,
            args.shell,
            args.state_version,
        ),
        interactive=interactive,
        choice=args.select,
        fallback_rel="modules/00-user.nix",
    )
    runtime_clone = os.path.join("/home", args.username, args.clone_relative)
    flake_structure.ensure_host(
        root,
        args.hostname,
        runtime_clone,
        interactive=interactive,
        choice=args.select,
        fallback_rel="modules/00-host.nix",
    )
    flake_structure.ensure_imports(
        root,
        ["system-configuration", "users"],
        interactive=interactive,
        choice=args.select,
        fallback_rel="modules/00-imports.nix",
    )


def main():
    parser = argparse.ArgumentParser(
        description="Prepare a fresh ojuny-template repository for installation."
    )
    parser.add_argument("--root", required=True, help="Target repository path.")
    parser.add_argument("--template", required=True, help="Template source path.")
    parser.add_argument("--username", required=True)
    parser.add_argument("--fullname", default=None)
    parser.add_argument("--hashed-password", default="!")
    parser.add_argument("--shell", choices=["zsh", "bash", "fish"], default="zsh")
    parser.add_argument("--hostname", required=True)
    parser.add_argument("--timezone", default=None)
    parser.add_argument("--locale", default=None)
    parser.add_argument("--keymap", default=None)
    parser.add_argument("--state-version", default="26.11")
    parser.add_argument("--clone-relative", default="repos/nix-flake")
    parser.add_argument("--force", action="store_true")
    parser.add_argument("--non-interactive", action="store_true")
    parser.add_argument("--select", default=None, help="explicit module file choice")
    args = parser.parse_args()

    if not re.fullmatch(r"[a-z_][a-z0-9_-]*", args.username):
        parser.error("invalid username: {}".format(args.username))
    if not re.fullmatch(r"[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?", args.hostname):
        parser.error("invalid hostname: {}".format(args.hostname))
    if args.fullname is None:
        args.fullname = args.username

    try:
        copy_template(args.template, args.root, args.force)
        configure(args, args.root)
    except Exception as error:
        print("prepare-repo: {}".format(error), file=sys.stderr)
        return 1

    print("prepare-repo: prepared {}".format(args.root))
    return 0


if __name__ == "__main__":
    sys.exit(main())
