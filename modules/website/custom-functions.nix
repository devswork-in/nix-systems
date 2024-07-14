{ pkgs }:

{
  fetchOrUpdateRepo = { url, location }: ''
    ${pkgs.bash}/bin/bash -c '\
    if [ ! -d "$location" ]; then \
      ${pkgs.git}/bin/git clone --depth=1 $url "${location}" &>/dev/null && \
      echo "Cloning complete!"; \
    else \
      echo "Debug: Directory ${location} already exists and is not empty."; \
      cd "${location}" && ${pkgs.git}/bin/git pull &>/dev/null && \
      echo "Successfully updated ${location}"; \
    fi;\
    '
  '';
}

