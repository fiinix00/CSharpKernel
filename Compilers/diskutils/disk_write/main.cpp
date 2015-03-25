#include <Windows.h>
#include <stdio.h>

int fsize(FILE *fp)
{
	int prev = ftell(fp);
	fseek(fp, 0L, SEEK_END);
	int sz = ftell(fp);
	fseek(fp, prev, SEEK_SET); //go back to where we were
	return sz;
}

int main(int argc, char *argv[]){
	FILE *fh;
	HANDLE disk;
	int len_r = 0;
	DWORD len_w = 0;
	
	char *image_path;
	char *disk_path;

	int offset = 0;
	int size = 0;

	if (argc >= 4){
		image_path = argv[1];
		disk_path = argv[2];
		
		offset = atoi(argv[3]);

		printf("Image: %s\n", image_path);
		fh = fopen(image_path, "rb");
		
		if (fh)
		{
			if (argc >= 5)
			{
				size = atoi(argv[4]);
			}
			else
			{
				size = fsize(fh);
			}

			char* image = (char*)malloc(size);

			len_r = fread(image, sizeof(char), size, fh);
			fclose(fh);
			printf("Read: %d bytes\n", len_r);
			printf("Disk: %s\n", disk_path);

			disk = CreateFileA(disk_path, FILE_ALL_ACCESS, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL | FILE_FLAG_WRITE_THROUGH, NULL); 
			//fh = fopen(disk_path, "wb");
			if (disk != INVALID_HANDLE_VALUE){
				//len = fwrite(image, sizeof(char), len, fh);
				
				DWORD seek = SetFilePointer(disk, offset, NULL, FILE_BEGIN);
				if (seek == INVALID_SET_FILE_POINTER)
				{
					printf("Failed to set seek pointer\n");
				}
				else
				{
					int written = 0;
					while (size > 0)
					{
						int write = (size >= 512 ? 512 : size);

						if (WriteFile(disk, image + written, write, &len_w, NULL) == TRUE){
							//printf("Write: %d bytes\n", len_w);
						}
						else {
							printf("Error writing image");
						}

						size -= len_w;
						written += len_w;
					}
				}
				CloseHandle(disk);
				//fclose(fh);
			} else {
				printf("Could not open Disk!\n");
			}
		} else {
			printf("Could not open Image!\n");
		}
	} else {
		printf("No image or disk selected. Syntax: disk_write image.bin \\\\.\\disk");
	}
	
	return 0;
}