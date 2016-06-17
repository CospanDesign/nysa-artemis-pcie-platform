#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

MODULE_INFO(vermagic, VERMAGIC_STRING);

__visible struct module __this_module
__attribute__((section(".gnu.linkonce.this_module"))) = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

static const struct modversion_info ____versions[]
__used
__attribute__((section("__versions"))) = {
	{ 0x3bb98123, __VMLINUX_SYMBOL_STR(module_layout) },
	{ 0x1fedf0f4, __VMLINUX_SYMBOL_STR(__request_region) },
	{ 0x92428f4b, __VMLINUX_SYMBOL_STR(cdev_del) },
	{ 0x5e581c3f, __VMLINUX_SYMBOL_STR(kmalloc_caches) },
	{ 0xe16c6503, __VMLINUX_SYMBOL_STR(cdev_init) },
	{ 0x69a358a6, __VMLINUX_SYMBOL_STR(iomem_resource) },
	{ 0x754d539c, __VMLINUX_SYMBOL_STR(strlen) },
	{ 0x97868aef, __VMLINUX_SYMBOL_STR(__kfifo_alloc) },
	{ 0xc2bd858e, __VMLINUX_SYMBOL_STR(pci_disable_device) },
	{ 0x6dc0c9dc, __VMLINUX_SYMBOL_STR(down_interruptible) },
	{ 0x9b7b967a, __VMLINUX_SYMBOL_STR(device_destroy) },
	{ 0x7485e15e, __VMLINUX_SYMBOL_STR(unregister_chrdev_region) },
	{ 0x426c9b71, __VMLINUX_SYMBOL_STR(device_create_with_groups) },
	{ 0x4f8b5ddb, __VMLINUX_SYMBOL_STR(_copy_to_user) },
	{ 0xbb805f3, __VMLINUX_SYMBOL_STR(pci_set_master) },
	{ 0xf8c6c4fd, __VMLINUX_SYMBOL_STR(dev_err) },
	{ 0x156a8a59, __VMLINUX_SYMBOL_STR(down_trylock) },
	{ 0x27e1a049, __VMLINUX_SYMBOL_STR(printk) },
	{ 0x20c55ae0, __VMLINUX_SYMBOL_STR(sscanf) },
	{ 0x4c9d28b0, __VMLINUX_SYMBOL_STR(phys_base) },
	{ 0x2072ee9b, __VMLINUX_SYMBOL_STR(request_threaded_irq) },
	{ 0x7ba37b16, __VMLINUX_SYMBOL_STR(cdev_add) },
	{ 0xd3f949d7, __VMLINUX_SYMBOL_STR(pci_disable_link_state) },
	{ 0x2546e244, __VMLINUX_SYMBOL_STR(pcie_set_mps) },
	{ 0x42c8de35, __VMLINUX_SYMBOL_STR(ioremap_nocache) },
	{ 0xdb7305a1, __VMLINUX_SYMBOL_STR(__stack_chk_fail) },
	{ 0x1000e51, __VMLINUX_SYMBOL_STR(schedule) },
	{ 0xbdfb6dbb, __VMLINUX_SYMBOL_STR(__fentry__) },
	{ 0x7c61340c, __VMLINUX_SYMBOL_STR(__release_region) },
	{ 0x8e20a9ce, __VMLINUX_SYMBOL_STR(pci_enable_msi_range) },
	{ 0x3b4eadd9, __VMLINUX_SYMBOL_STR(pci_unregister_driver) },
	{ 0x5a11f3ba, __VMLINUX_SYMBOL_STR(kmem_cache_alloc_trace) },
	{ 0xdb760f52, __VMLINUX_SYMBOL_STR(__kfifo_free) },
	{ 0x37a0cba, __VMLINUX_SYMBOL_STR(kfree) },
	{ 0xa5b655a, __VMLINUX_SYMBOL_STR(pci_disable_msi) },
	{ 0x4ce91efb, __VMLINUX_SYMBOL_STR(dma_supported) },
	{ 0xedc03953, __VMLINUX_SYMBOL_STR(iounmap) },
	{ 0x78e739aa, __VMLINUX_SYMBOL_STR(up) },
	{ 0xaa72578f, __VMLINUX_SYMBOL_STR(__pci_register_driver) },
	{ 0x625f0222, __VMLINUX_SYMBOL_STR(class_destroy) },
	{ 0x28318305, __VMLINUX_SYMBOL_STR(snprintf) },
	{ 0x436c2179, __VMLINUX_SYMBOL_STR(iowrite32) },
	{ 0xb8c09cad, __VMLINUX_SYMBOL_STR(pci_enable_device) },
	{ 0x4f6b400b, __VMLINUX_SYMBOL_STR(_copy_from_user) },
	{ 0xcf02e318, __VMLINUX_SYMBOL_STR(__class_create) },
	{ 0x7a207620, __VMLINUX_SYMBOL_STR(dma_ops) },
	{ 0x29537c9e, __VMLINUX_SYMBOL_STR(alloc_chrdev_region) },
	{ 0xf20dabd8, __VMLINUX_SYMBOL_STR(free_irq) },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=";

MODULE_ALIAS("pci:v000010EEd00000007sv*sd*bc*sc*i*");

MODULE_INFO(srcversion, "5FFD579D5DB4A431EECF228");
