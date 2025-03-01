HOST=${HOST:="molyett.com"}
DEST=${DEST:='~/www/haxe/GoldphishMatcher'}
VERSION=${VERSION:="1.7.1"}
PROJECT="GoldphishMatcher"

FULL_PATH_TO_SCRIPT="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIRECTORY="$(dirname "$FULL_PATH_TO_SCRIPT")"
EXPORT_DIRECTORY="$(realpath "${SCRIPT_DIRECTORY}/../exports")"
ROOT_DIRECTORY="$(realpath "${SCRIPT_DIRECTORY}/../")"

HTML5_DIRECTORY="$(realpath "${EXPORT_DIRECTORY}/HTML5")"
WINDOWS_DIRECTORY="$(realpath "${EXPORT_DIRECTORY}/Windows")"
ANDROID_DIRECTORY="$(realpath "${EXPORT_DIRECTORY}/Android")"

pushd $HTML5_DIRECTORY
zip -r $EXPORT_DIRECTORY/releases/${PROJECT}.html5.${VERSION}.zip ./*
rsync -av ./* "$HOST:$DEST"
rm ./*
popd

pushd $WINDOWS_DIRECTORY
zip -r $EXPORT_DIRECTORY/releases/${PROJECT}.windows.${VERSION}.zip ./*
rm ./*
popd

pushd $ANDROID_DIRECTORY
mv $PROJECT.aab $EXPORT_DIRECTORY/releases/${PROJECT}.android.${VERSION}.aab
popd
