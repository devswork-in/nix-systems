function blur
  if [ -z $argv[1] ]
    echo "Usage: blur 10 screenshot.jpg #10% blur"
  else
    convert -scale (math 100 - $argv[1])% -scale 1000% $argv[2] blurred-$argv[2];
    v blurred-$argv[2];
  end
end
