// SPDX-License-Identifier: GPL-2.0-or-later
// Standalone repeatability check for hosts without DejaGNU.
use std::{env, fs, path::PathBuf, process::Command};

fn main() {
    let args: Vec<_> = env::args_os().collect();
    assert_eq!(
        args.len(),
        4,
        "usage: check-cselib <xgcc> <fixture.c> <output-dir>"
    );
    let driver = fs::canonicalize(&args[1]).unwrap();
    let output = PathBuf::from(&args[3]);
    fs::create_dir_all(&output).unwrap();
    let assembly = output.join("cselib-constant-mode.s");
    let mut previous = None;
    for run in 0..300 {
        let result = Command::new(&driver)
            .arg(format!("-B{}/", driver.parent().unwrap().display()))
            .args([
                "-S",
                "-O2",
                "-mthumb",
                "-mthumb-interwork",
                "-mcpu=arm7tdmi",
            ])
            .arg(&args[2])
            .arg("-o")
            .arg(&assembly)
            .output()
            .unwrap();
        assert!(
            result.status.success(),
            "{}",
            String::from_utf8_lossy(&result.stderr)
        );
        let text = fs::read_to_string(&assembly).unwrap();
        assert_eq!(
            text.matches("#205").count(),
            1,
            "run {run}: duplicated constant"
        );
        assert!(
            text.contains("\tmov\tr2, r1"),
            "run {}: missing value reuse",
            run
        );
        assert!(
            text.contains("\tstrh\t"),
            "run {}: missing narrow store",
            run
        );
        assert!(text.contains("\tstr\t"), "run {}: missing wide store", run);
        if let Some(ref last) = previous {
            assert_eq!(last, &text, "run {run}: non-reproducible assembly");
        }
        previous = Some(text);
    }
    println!("300 identical compilations; same-mode reuse and mixed-width stores pass");
}
