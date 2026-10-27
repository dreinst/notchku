# Daftarkan berkas Swift baru ke project.pbxproj, ditaruh di sebelah EventMonitors.swift.
import sys, uuid, re
pbx = "NotchDrop.xcodeproj/project.pbxproj"
s = open(pbx).read()
anchor = "504381AB2C3A95BD000ED325 /* EventMonitors.swift */"
anchor_build = "504381AC2C3A95BD000ED325 /* EventMonitors.swift in Sources */"
for name in sys.argv[1:]:
    if f"path = {name};" in s:
        continue
    ref, build = (uuid.uuid4().hex[:24].upper() for _ in range(2))
    s = s.replace(f"\t\t{anchor_build} = {{",
        f"\t\t{build} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {ref} /* {name} */; }};\n\t\t{anchor_build} = {{", 1)
    s = s.replace(f"\t\t{anchor} = {{",
        f"\t\t{ref} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = {name}; sourceTree = \"<group>\"; }};\n\t\t{anchor} = {{", 1)
    s = s.replace(f"\t\t\t\t{anchor},", f"\t\t\t\t{anchor},\n\t\t\t\t{ref} /* {name} */,", 1)
    s = s.replace(f"\t\t\t\t{anchor_build},", f"\t\t\t\t{anchor_build},\n\t\t\t\t{build} /* {name} in Sources */,", 1)
open(pbx, "w").write(s)
