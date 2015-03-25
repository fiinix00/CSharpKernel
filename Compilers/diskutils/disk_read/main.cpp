#include <Windows.h>
#include <stdio.h>

int main(int argc, char *argv[]){
	FILE *fh;
	HANDLE disk;
	DWORD len_r = 0;
	int len_w = 0;
	char image[512];
	char *image_path;
	char *disk_path;

	if (argc >= 3){
		disk_path = argv[1];
		image_path = argv[2];
		
		printf("Disk: %s\n", disk_path);
		disk = CreateFileA(disk_path, FILE_ALL_ACCESS, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL | FILE_FLAG_WRITE_THROUGH, NULL); 
		//fh = fopen(disk_path, "wb");
		if (disk != INVALID_HANDLE_VALUE){
			//len = fwrite(image, sizeof(char), len, fh);
			if (ReadFile(disk, image, 512, &len_r, NULL) == TRUE){
				printf("Read: %d bytes\n", len_r);
				fh = fopen(image_path, "wb");
				if (fh){
					len_w = fwrite(image, sizeof(char), 512, fh);
					fclose(fh);
					printf("Write: %d bytes\n", len_w);
				} else {
					printf("Could not open Image!\n");
				}
			} else {
				printf("Error reading disk");
			}
			CloseHandle(disk);
			//fclose(fh);
		} else {
			printf("Could not open Disk!\n");
		}
	} else {
		printf("No image or disk selected. Syntax: disk_write \\\\.\\disk image.bin");
	}
	
	return 0;
}