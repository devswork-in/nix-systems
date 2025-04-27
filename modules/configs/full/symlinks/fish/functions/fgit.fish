function fgit
  if test -z "$argv[1]"
    echo "Usage: fgit <repository-url> [subdirectory]"
    echo "Examples:"
    echo "  fgit https://github.com/user/repo"
    echo "  fgit https://github.com/user/repo specific/folder"
    echo "  fgit https://github.com/user/repo/tree/main/specific/folder"
    return 1
  end

  set -l repo_url $argv[1]
  set -l target_subdir $argv[2]
  
  # Handle GitHub URLs with /tree/ paths
  if string match -q "*github.com*/tree/*" -- $repo_url
    # Extract the target subdirectory from URL if it contains /tree/branch/
    set -l parts (string match -r "github\.com/([^/]+/[^/]+)/tree/[^/]+/(.*)" $repo_url)
    if test -n "$parts"
      # Set the clean repo URL
      set repo_url "https://github.com/$parts[2]"
      # If no explicit subdir was provided, use the one from URL
      if test -z "$target_subdir"
        set target_subdir $parts[3]
      end
    end
  end

  # Extract repository name from URL
  if string match -q "git@*" -- $repo_url
    set dirname (echo $repo_url | string split ':' | string split '.' | head -n 1 | tail -n 1)
  else
    set dirname (basename $repo_url .git)
  end

  set -l original_dir (pwd)
  
  # Provide feedback
  echo "Sparse cloning repository: $repo_url"
  if test -n "$target_subdir"
    echo "Target subdirectory: $target_subdir"
  end
  
  # Clone repository with sparse checkout
  if not git clone --filter=blob:none --no-checkout --depth 1 --sparse $repo_url 2>/dev/null
    echo "Error: Failed to clone repository. Please check the URL and try again."
    return 1
  end
  
  cd $dirname

  git sparse-checkout init --cone
  
  # If subdirectory was determined earlier, use it
  if test -n "$target_subdir"
    set subdir $target_subdir
  else
    # Otherwise ask user for input
    echo
    read -P "Enter subdirectory to fetch from $dirname/: " subdir
    echo
  end
  
  if test -z "$subdir"
    echo "No subdirectory specified. Aborting."
    cd $original_dir
    rm -rf $dirname
    return 1
  end
  
  # Try to add the subdirectory
  if not git sparse-checkout add $subdir 2>/dev/null
    echo "Warning: Could not find $subdir. Checking available directories..."
    git ls-tree -d --name-only HEAD
    cd $original_dir
    rm -rf $dirname
    return 1
  end
  
  # Checkout the content
  git checkout
  
  # Check if subdirectory exists after checkout
  if not test -d $subdir
    echo "Error: Subdirectory $subdir not found after checkout."
    cd $original_dir
    rm -rf $dirname
    return 1
  end
  
  # Move the requested directory to original location
  mv $subdir $original_dir/
  
  cd $original_dir
  
  # Remove the temporary repo directory
  rm -rf $dirname
  
  echo "Successfully fetched $subdir"
end
