{
  flake.nixosModules.resume = { unstable, username, ... }: {
    home-manager.users.${username}.home.packages = [ unstable.typst unstable.poppler-utils ];
  };

  perSystem = { unstable, ... }:
    let
      resume = unstable.writeShellApplication {
        name = "resume";
        runtimeInputs = with unstable; [ typst coreutils ];
        text = ''
          out="$(realpath -m "''${1:-resume.pdf}")"
          cd "''${RESUME_DIR:-$HOME/dotfiles/modules/resume}"
          typst compile --ignore-system-fonts layout.typ "$out"
          echo "wrote $out"
        '';
      };
    in
    {
      # nix run ~/dotfiles#resume [out.pdf] -> compile content.typ
      apps.resume.program = resume;

      # nix run ~/dotfiles#resume-update [Profile.pdf] [out.pdf] -> sync
      apps.resume-update.program = unstable.writeShellApplication {
        name = "resume-update";
        runtimeInputs = with unstable; [ poppler-utils claude-code git coreutils ];
        text = ''
          pdf="''${1:-$HOME/Downloads/Profile.pdf}"
          out="$(realpath -m "''${2:-resume.pdf}")"
          cd "''${RESUME_DIR:-$HOME/dotfiles/modules/resume}"

          pdftotext -layout "$pdf" - | claude -p --allowedTools 'Read Edit' \
            "stdin is a pdftotext dump of my latest LinkedIn Profile.pdf export. \
          Update ./content.typ so its data matches the export: new or removed roles, \
          edited bullets, dates, titles, skills. Keep the existing structure per role \
          (intro, bullets, stack), plain ASCII hyphens in date ranges, and valid Typst \
          data syntax. Do not modify layout.typ or any other file. If nothing changed, \
          say so. End with a short summary of what you changed."

          git diff --stat -- content.typ
          ${resume}/bin/resume "$out"
        '';
      };
    };
}
