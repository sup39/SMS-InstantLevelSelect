# SMS Instant Level Select

## Usage
- Press `B + D-Pad Up` to **restart the current area**
  - The **respawn position** will be the same. It can be used to practice Honey Skip or stage movement in Delfino Plaza
- Press `{button of Level Select} + B + D-Pad Up` to activate Level Select immediately
  - For `Z + B + D-Pad Up`, the current area will be restarted, but the **respawn position will be reset**. It is like B+DPad_Up, but the respawn position will be the default position instead of the previous one
  - For `Y + B + D-Pad Up`, it will restart from the **previous selected area**. For example, if you select SB4 with this code, and enter hotel/casino then press Y+B+DPad_Up, it will restart from SB4 beach (instead of hotel/casino if you use B+DPad_Up or Z+B+DPad_Up)
  - NOTE: **Z menu will be disabled**
- Press `R + D-Pad Left/Right` to enable/disable **Area Lock**
  - With Area Lock, warps will restart the current area instead of sending Mario to other areas, which can be used to practice specific area (e.g. outside of BH2 wildmill, secret stage entering)
  - Restarting acts like B+DPad_Up, and therefore can be used to practice Honey Skip, etc.

## Build
You can use [supSMSASM](https://github.com/sup39/supSMSASM) to build the code:
```bash
# build for JP 1.0
supSMSASM InstantLevelSelect.s

# build for JP 1.1 (not tested)
supSMSASM InstantLevelSelect.s JPA
```
