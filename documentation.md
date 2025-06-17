# Documentation

### Running `mips`:

```bash
qemu-system-mips  \
  -M malta \
  -m 256 \
  -kernel build/vmlinux \
  -initrd build/initrd.gz \
  -nographic \
  -append "root=/dev/ram0 rdinit=/init" \
  -net nic,model=pcnet32 \
  -net user
```
