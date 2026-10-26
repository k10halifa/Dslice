ACCOUNT="${GITHUB_USER:-William0Taylor0}"
VERSION="6.3"

unset GITHUB_TOKEN
gh auth setup-git 2>/dev/null || true

git remote set-url origin "https://github.com/${ACCOUNT}/Dslice.git"
git checkout master

git add -A
git commit -m "Save my local modifications before sync" 2>/dev/null || true

git remote remove upstream 2>/dev/null || true
git remote add upstream https://github.com/diabl0w/DFRoot.git
git fetch upstream master

git merge upstream/master --allow-unrelated-histories -X ours --no-edit || true
git checkout upstream/master -- .github/ lkm/ 2>/dev/null || git checkout upstream/master -- .github/

find . -type f \( -name "build.gradle" -o -name "build.gradle.kts" \) -exec sed -i \
    -e 's/applicationId\s*=\s*"[^"]*"/applicationId = "df.D10slice"/g' \
        -e "s/applicationId\s*'[^']*'/applicationId 'df.D10slice'/g" \
            -e 's/applicationId\s\+"[^"]*"/applicationId "df.D10slice"/g' \
                -e "s/versionName\s*=\s*\"[^\"]*\"/versionName = \"$VERSION\"/g" \
                    -e "s/versionName\s*'[^']*'/versionName '$VERSION'/g" \
                        -e "s/versionName\s\+\"[^\"]*\"/versionName \"$VERSION\"/g" \
                            -e 's/DFRoot_/Dslice/g' \
                                -e 's/Dslice_/Dslice/g' {} +

                                find . -type f -name "strings.xml" -exec sed -i \
                                    -e 's/<string name="app_name">[^<]*<\/string>/<string name="app_name">Dslice<\/string>/g' {} +

                                    export VERSION
                                    python3 - << 'EOF'
                                    import glob, re, subprocess, base64, os

                                    ver = os.environ.get("VERSION", "6.4")
                                    apk_base = f"Dslice{ver}"
                                    apk_filename = f"{apk_base}.apk"

                                    b64_cache = ".keystore_b64"
                                    ks_b64 = ""

                                    if os.path.exists(b64_cache):
                                        with open(b64_cache, "r", encoding="utf-8") as f:
                                                ks_b64 = f.read().strip()
                                                else:
                                                    keystore_file = "auto_release.jks"
                                                        if os.path.exists(keystore_file):
                                                                os.remove(keystore_file)
                                                                    try:
                                                                            subprocess.run([
                                                                                        "keytool", "-genkeypair", "-v",
                                                                                                    "-keystore", keystore_file,
                                                                                                                "-keyalg", "RSA", "-keysize", "2048", "-validity", "10000",
                                                                                                                            "-alias", "dslice",
                                                                                                                                        "-storepass", "Dslice123456",
                                                                                                                                                    "-keypass", "Dslice123456",
                                                                                                                                                                "-dname", "CN=Dslice, OU=Dev, O=Dslice, L=Cairo, S=Cairo, C=EG"
                                                                                                                                                                        ], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                                                                                                                                                                                with open(keystore_file, "rb") as f:
                                                                                                                                                                                            ks_b64 = base64.b64encode(f.read()).decode("utf-8")
                                                                                                                                                                                                    with open(b64_cache, "w", encoding="utf-8") as f:
                                                                                                                                                                                                                f.write(ks_b64)
                                                                                                                                                                                                                        os.remove(keystore_file)
                                                                                                                                                                                                                            except Exception:
                                                                                                                                                                                                                                    pass

                                                                                                                                                                                                                                    for path in glob.glob(".github/workflows/*.y*ml"):
                                                                                                                                                                                                                                        with open(path, "r", encoding="utf-8") as f:
                                                                                                                                                                                                                                                content = f.read()

                                                                                                                                                                                                                                                    content = re.sub(
                                                                                                                                                                                                                                                            r'(echo\s+"::error::Signing secrets not configured[^\n]*\n\s*)exit\s+1',
                                                                                                                                                                                                                                                                    r'\1echo "Bypassing keystore error and continuing build..."',
                                                                                                                                                                                                                                                                            content
                                                                                                                                                                                                                                                                                )

                                                                                                                                                                                                                                                                                    if ks_b64:
                                                                                                                                                                                                                                                                                            content = content.replace("${{ secrets.KEYSTORE }}", f"${{{{ secrets.KEYSTORE || '{ks_b64}' }}}}")
                                                                                                                                                                                                                                                                                                content = content.replace("${{ secrets.KEYSTORE_PASSWORD }}", "${{ secrets.KEYSTORE_PASSWORD || 'Dslice123456' }}")
                                                                                                                                                                                                                                                                                                    content = content.replace("${{ secrets.KEY_STORE_PASSWORD }}", "${{ secrets.KEY_STORE_PASSWORD || 'Dslice123456' }}")
                                                                                                                                                                                                                                                                                                        content = content.replace("${{ secrets.KEY_ALIAS }}", "${{ secrets.KEY_ALIAS || 'dslice' }}")
                                                                                                                                                                                                                                                                                                            content = content.replace("${{ secrets.KEY_PASSWORD }}", "${{ secrets.KEY_PASSWORD || 'Dslice123456' }}")

                                                                                                                                                                                                                                                                                                                content = re.sub(r'(\bname:\s*)DFRoot\b', rf'\1{apk_base}', content)
                                                                                                                                                                                                                                                                                                                    content = content.replace('DFRoot-v', 'Dslice-v')

                                                                                                                                                                                                                                                                                                                        rename_cmd = f"""      - name: Prepare {apk_filename}
                                                                                                                                                                                                                                                                                                                                run: |
                                                                                                                                                                                                                                                                                                                                          FOUND_APK=$(find app/build/outputs/apk -type f -name "*.apk" | head -n 1)
                                                                                                                                                                                                                                                                                                                                                    if [ -n "$FOUND_APK" ]; then
                                                                                                                                                                                                                                                                                                                                                                DIR_PATH=$(dirname "$FOUND_APK")
                                                                                                                                                                                                                                                                                                                                                                            mv -f "$FOUND_APK" "$DIR_PATH/{apk_filename}"
                                                                                                                                                                                                                                                                                                                                                                                      fi
                                                                                                                                                                                                                                                                                                                                                                                      """
                                                                                                                                                                                                                                                                                                                                                                                          if f"Prepare {apk_filename}" not in content:
                                                                                                                                                                                                                                                                                                                                                                                                  content = re.sub(
                                                                                                                                                                                                                                                                                                                                                                                                              r'(\n\s*-\s+name:\s*Upload[^\n]+)',
                                                                                                                                                                                                                                                                                                                                                                                                                          r'\n' + rename_cmd + r'\1',
                                                                                                                                                                                                                                                                                                                                                                                                                                      content,
                                                                                                                                                                                                                                                                                                                                                                                                                                                  count=1
                                                                                                                                                                                                                                                                                                                                                                                                                                                          )

                                                                                                                                                                                                                                                                                                                                                                                                                                                              content = content.replace('app/build/outputs/apk/release/DFRoot_*.apk', f'app/build/outputs/apk/**/{apk_filename}')
                                                                                                                                                                                                                                                                                                                                                                                                                                                                  content = re.sub(r'\n\s*app/build/outputs/apk/debug/DFRoot_\*\.apk', '', content)
                                                                                                                                                                                                                                                                                                                                                                                                                                                                      content = content.replace('DFRoot_*.apk', apk_filename)

                                                                                                                                                                                                                                                                                                                                                                                                                                                                          with open(path, "w", encoding="utf-8") as f:
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  f.write(content)

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  print(f"Workflows patched! Account: {os.environ.get('GITHUB_USER', 'current')} | Outer: {apk_base}.zip | Inner: {apk_filename}")
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  EOF

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  git add -A
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  git commit -m "Update Dslice to $VERSION (Outer: Dslice${VERSION}.zip, Inner: Dslice${VERSION}.apk)" --allow-empty
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  git push origin master --force
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  