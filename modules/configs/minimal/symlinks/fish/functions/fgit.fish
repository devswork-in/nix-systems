function fgit
  if test -z "$argv[1]"
    echo "Usage: fgit <repository-url> [subdirectory]"
    echo "Examples:"
    echo "  fgit https://github.com/user/repo"
    echo "  fgit https://github.com/user/repo specific/folder"
    return 1
  end

  # Extract repository name from URL
  if string match -q "git@*" -- $argv[1]
    set dirname (echo $argv[1] | string split ':' | string split '.' | head -n 1 | tail -n 1)
  else
    set dirname (basename $argv[1] .git)
  end

  set -l original_dir (pwd)
  
  # Provide feedback
  echo "Sparse cloning repository..."
  
  # Clone repository with sparse checkout
  if not git clone --filter=blob:none --no-checkout --depth 1 --sparse $argv[1] 2>/dev/null
    echo "Error: Failed to clone repository. Please check the URL and try again."
    return 1
  end
  
  cd $dirname

  git sparse-checkout init --cone
  
  # If subdirectory is provided as argument, use it
  if test -n "$argv[2]"
    set subdir $argv[2]
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
