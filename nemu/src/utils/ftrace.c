#include "ftrace.h"

void print_symbol(Elf32_Sym *sym, const char *strtab) {
    const char *name = strtab + sym->st_name;
    printf("  %-40s 0x%08lx\n", name, (unsigned long)sym->st_value);
}
int process_elf_file(const char* filename) {
    printf("reading elf_file %s...\n",filename);
    FILE *file = fopen(filename, "rb");
    if (!file) {
        perror("fopen failed");
        return 1;
    }
    //打开ELF头表
    Elf32_Ehdr ehdr;
     if (fread(&ehdr, sizeof(ehdr), 1, file) != 1) {
        perror("Failed to read ELF header");
        fclose(file);
        return 1;
    }
    // typedef struct {
    //     unsigned char e_ident[EI_NIDENT];//魔数
    //     uint16_t      e_type;            //elf文件类型
    //     uint16_t      e_machine;         
    //     uint32_t      e_version;         
    //     ElfN_Addr     e_entry;           //程序入口的地址
    //     ElfN_Off      e_phoff;           //program程序头表偏移地址
    //     ElfN_Off      e_shoff;           //section节头表偏移地址
    //     uint32_t      e_flags;           
    //     uint16_t      e_ehsize;          //elf本身文件大小
    //     uint16_t      e_phentsize;       //程序头表每个条目entry的大小
    //     uint16_t      e_phnum;           //程序头表条目数量
    //     uint16_t      e_shentsize;       //和上面类似
    //     uint16_t      e_shnum;
    //     uint16_t      e_shstrndx;        //节头字符串表（.shstrtab） 在节头表中的索引。
    // } ElfN_Ehdr;   

    // 检查ELF魔数
    if (memcmp(ehdr.e_ident, ELFMAG, SELFMAG) != 0) {
        fprintf(stderr, "Not an ELF file\n");
        fclose(file);
        return 1;
    }

    // 定位节头表
    fseek(file, ehdr.e_shoff, SEEK_SET);
    Elf32_Shdr *shdrs = malloc(ehdr.e_shentsize * ehdr.e_shnum);
    if (!shdrs) {
        perror("malloc failed");
        fclose(file);
        return 1;
    }
    if (fread(shdrs, ehdr.e_shentsize, ehdr.e_shnum, file) != ehdr.e_shnum) {
        perror("Failed to read section headers");
        free(shdrs);
        fclose(file);
        return 1;
    }  
    //     typedef struct {
    //     uint32_t   sh_name;          //节名称，比如.text，存在节头字符串表
    //     uint32_t   sh_type;          //节的类型，比如SHT_PROGBITS 程序数据（如代码 .text、数据 .data）。
    //     uint32_t   sh_flags;
    //     Elf32_Addr sh_addr;          //如果节在运行时需要加载到内存，此字段表示节的虚拟地址
    //     Elf32_Off  sh_offset;
    //     uint32_t   sh_size;
    //     uint32_t   sh_link;
    //     uint32_t   sh_info;
    //     uint32_t   sh_addralign;     //节的内存对齐要求（必须是 2 的幂）
    //     uint32_t   sh_entsize;       //节的大小
    // } Elf32_Shdr;
    
    Elf32_Shdr *shstrtab_hdr = &shdrs[ehdr.e_shstrndx];//shdrs[ehdr.e_shstrndx]得到的是一个结构体，
    char *shstrtab = malloc(shstrtab_hdr->sh_size);
    if (!shstrtab) {
        perror("malloc failed");
        free(shdrs);
        fclose(file);
        return 1;
    }

    fseek(file, shstrtab_hdr->sh_offset, SEEK_SET);
    if (fread(shstrtab, shstrtab_hdr->sh_size, 1, file) != 1) {
        perror("Failed to read section header string table");
        free(shstrtab);
        free(shdrs);
        fclose(file);
        return 1;
    }

    Elf32_Shdr *symtab_hdr = NULL;
    Elf32_Shdr *strtab_hdr = NULL;

    for (int i = 0; i < ehdr.e_shnum; i++) {
        const char *name = shstrtab + shdrs[i].sh_name;
        
        if (shdrs[i].sh_type == SHT_SYMTAB && strcmp(name, ".symtab") == 0) {
            symtab_hdr = &shdrs[i];
        } else if (shdrs[i].sh_type == SHT_STRTAB && strcmp(name, ".strtab") == 0) {
            strtab_hdr = &shdrs[i];
        }
    }

    if (!symtab_hdr || !strtab_hdr) {
        fprintf(stderr, "Symbol table or string table not found\n");
        free(shstrtab);
        free(shdrs);
        fclose(file);
        return 1;
    }

    // 5. 读取字符串表
    char *strtab = malloc(strtab_hdr->sh_size);
    if (!strtab) {
        perror("malloc failed");
        free(shstrtab);
        free(shdrs);
        fclose(file);
        return 1;
    }

    fseek(file, strtab_hdr->sh_offset, SEEK_SET);
    if (fread(strtab, strtab_hdr->sh_size, 1, file) != 1) {
        perror("Failed to read string table");
        free(strtab);
        free(shstrtab);
        free(shdrs);
        fclose(file);
        return 1;
    }

    // 6. 读取符号表
    int num_symbols = symtab_hdr->sh_size / sizeof(Elf32_Sym);
    Elf32_Sym *symtab = malloc(symtab_hdr->sh_size);
    if (!symtab) {
        perror("malloc failed");
        free(strtab);
        free(shstrtab);
        free(shdrs);
        fclose(file);
        return 1;
    }

    fseek(file, symtab_hdr->sh_offset, SEEK_SET);
    if (fread(symtab, sizeof(Elf32_Sym), num_symbols, file) != num_symbols) {
        perror("Failed to read symbol table");
        free(symtab);
        free(strtab);
        free(shstrtab);
        free(shdrs);
        fclose(file);
        return 1;
    }
    // typedef struct {
    //     Elf32_Word    st_name;    // 符号名称索引
    //     Elf32_Addr    st_value;   // 符号的值
    //     Elf32_Word    st_size;    // 符号的大小
    //     unsigned char st_info;    // 类型和绑定属性
    //     unsigned char st_other;   // 保留字段
    //     Elf32_Section st_shndx;   // 所属节索引
    // } Elf32_Sym;

    //  打印符号表
    printf("Symbol table:\n");
    for (int i = 0; i < num_symbols; i++) {
        if (symtab[i].st_name != 0) {  // 跳过无名符号
            print_symbol(&symtab[i], strtab);
        }
    }

    free(symtab);
    free(strtab);
    free(shstrtab);
    free(shdrs);
    fclose(file);
    return 0;
}
