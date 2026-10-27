#!/bin/zsh
# Build sementara tanpa Xcode: SwiftPM di build/spm (bukan /tmp: Pow mencari resource bundle di path build ini), hasilnya build/NotchKu.app
set -e
R=${0:A:h:h}; C=$R/build/spm
mkdir -p $C/Sources && cp $R/scripts/Package.swift $C/Package.swift
rm -rf $C/Sources/NotchKu && cp -R $R/NotchDrop $C/Sources/NotchKu
python3 -c "
import glob
for p in glob.glob('$C/Sources/NotchKu/*.swift'):
    s=open(p).read(); i=s.find('#Preview')
    if i>=0: open(p,'w').write(s[:i])"
cd $C && swift build -c release 2>&1 | grep -E "error:|Build complete" | sort -u
B=$(swift build -c release --show-bin-path); A=$R/build/NotchKu.app
if [ ! -d $A ]; then
  mkdir -p $A/Contents/MacOS $A/Contents/Resources
  cp -R $B/*.bundle $A/Contents/Resources/ 2>/dev/null || true
  cp $R/NotchDrop/Info.plist $A/Contents/Info.plist
  for kv in "CFBundleIdentifier string dreinst.notchku" "CFBundleExecutable string NotchKu" "CFBundleName string NotchKu" \
            "CFBundlePackageType string APPL" "CFBundleShortVersionString string 0.1" "CFBundleVersion string 1" \
            "LSUIElement bool true" "LSMinimumSystemVersion string 14.0"; do
    /usr/libexec/PlistBuddy -c "Add :$kv" $A/Contents/Info.plist
  done
fi
cp $B/NotchKu $A/Contents/MacOS/NotchKu
codesign --force --deep -s "NotchKu Local" --entitlements $R/scripts/dev.entitlements $A
pkill -x NotchKu || true; sleep 0.5; open $A
