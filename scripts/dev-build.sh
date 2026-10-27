#!/bin/zsh
# Build sementara tanpa Xcode: SwiftPM di /tmp/notchku-check, hasilnya build/NotchKu.app
set -e
R=${0:A:h:h}; C=/tmp/notchku-check
rm -rf $C/Sources/NotchKu && cp -R $R/NotchDrop $C/Sources/NotchKu
python3 -c "
import glob
for p in glob.glob('$C/Sources/NotchKu/*.swift'):
    s=open(p).read(); i=s.find('#Preview')
    if i>=0: open(p,'w').write(s[:i])"
cd $C && swift build -c release 2>&1 | grep -E "error:|Build complete" | sort -u
B=$(swift build -c release --show-bin-path); A=$R/build/NotchKu.app
cp $B/NotchKu $A/Contents/MacOS/NotchKu
codesign --force --deep -s "NotchKu Local" --entitlements $C/ent.plist $A
pkill -x NotchKu || true; sleep 0.5; open $A
