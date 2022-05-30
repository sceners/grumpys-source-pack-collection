#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <time.h>
#include <math.h>

#define SNOW_MATERIAL   "WHITE MATTE"
#define WATER_MATERIAL  "BLUE GLASS"
#define GRASS_MATERIAL  "GREEN MATTE"
#define ROCK_MATERIAL   "BEIGE MATTE"

#define RAND_FNC        rand()

#define SIZE (unsigned long)((1 << ITER))
#define VARI (float)pow((double)VARI_CHANGE,(double)ITER)

char    FTYPE;
short   ITER=4;
short   MATERIAL=1;
float   VARI_CHANGE=2.00;
float   SEA=0.40;
float   SNOW=1.00;
short   XSIZE=200;
short   YSIZE=200;
short   ZSIZE=200;
float   x_pos;
float   y_pos;
unsigned long count1;
unsigned long count2;
unsigned long buf_size;
unsigned long faces;
FILE  *handle;
float huge *map;
float snow;
float water;
float altitude;
float min;
float max;
char  filename[81];

void iterate(long,long,long,long,float,float huge *);
void write_material(FILE *,
		    unsigned long,
		    unsigned long, unsigned long,
		    float huge *,
		    float, float, float);

int write_faces(FILE *hand, char FTYPE)
{
	if (FTYPE==0)
	{
		fprintf(hand,"Face list:\n");
		for (count1=0; count1<SIZE-1; count1++)
			for (count2=0; count2<SIZE-1; count2++)
			{
				fprintf(hand,"Face %lu:    A:%lu B:%lu C:%lu AB:1 BC:1 CA:1\n",
					count1*((SIZE-1)<<1)+count2*2,
					count1*SIZE+count2,
					count1*SIZE+count2+1,
					(count1+1)*SIZE+count2);
				if (MATERIAL)
					write_material(hand,
						count1*SIZE+count2,
						count1*SIZE+count2+1,
						(count1+1)*SIZE+count2,
						map,water,snow,altitude);
				fprintf(hand,"Face %lu:    A:%lu B:%lu C:%lu AB:1 BC:1 CA:1\n",
					count1*((SIZE-1)<<1)+count2*2+1,
					count1*SIZE+count2+1,
					(count1+1)*SIZE+count2+1,
					(count1+1)*SIZE+count2);
				if (MATERIAL)
					write_material(hand,
						count1*SIZE+count2+1,
						(count1+1)*SIZE+count2+1,
						(count1+1)*SIZE+count2,
						map,water,snow,altitude);
			}
	}

	return 0;
}


int     write_verts(FILE *hand, char FTYPE)
{
	if (FTYPE==0)
	{
		fprintf(hand,"Vertex list:\n");
		for (count1=0; count1<SIZE; count1++)
			for (count2=0; count2<SIZE; count2++)
				fprintf(hand,"Vertex %lu:  X: %f     Y: %f     Z: %f\n",
					count1*SIZE+count2,
					(float)(count2*XSIZE)/SIZE,(float)(count1*YSIZE)/SIZE,
					(float)(map[count1*SIZE+count2]*ZSIZE)/altitude);
	}

	if (FTYPE==1)
	{
		fprintf(hand,"\tLL_DATA\t");
		for (count1=0; count1<SIZE*8; count1++)
		{
			fprintf(hand,"db ");
			for (count2=0; count2<SIZE/8-1; count2++)
				fprintf(hand,"%2u,",(unsigned char)((float)((map[count1*(SIZE/8)+count2]-water)*ZSIZE)/altitude));
			fprintf(hand,"%2u\n\t\t",(unsigned char)((float)((map[count1*(SIZE/8)+count2]-water)*ZSIZE)/altitude));
		}
	}

	return 0;
}

FILE *init_file(char *fname,char FTYPE)
{
FILE *hand;
	if ((hand=fopen(fname,"wt"))==0)
		return 0;

	if (FTYPE==0)
	{
		fprintf(hand,"Ambient light color: Red=0.3 Green=0.3 Blue=0.3\n\n");
		fprintf(hand,"Named object: \"Fractal Mtn\"\n");
		fprintf(hand,"Tri-mesh, Vertices: %lu     Faces: %lu\n",buf_size,faces);
	}
	if (FTYPE==1)
	{
		fprintf(hand,";;\n");
		fprintf(hand,";; Lord Logics Landscape Mesh File\n");
		fprintf(hand,";;\n");
		fprintf(hand,".fardata\tLL_MESH\n");
	}

	return hand;
}


main(int argc, char *argv[])
{
	strcpy(filename,"");

	for (count1=1; count1<argc; count1++)
	{
		if ((argv[count1][0]!='\\') && (argv[count1][0]!='/') && (argv[count1][0]!='-'))
		{
			printf("3D Fractal Landscape Creator v1.5                   [12-08-92]\n");
			printf("Copyright (C) 1992-93 James P. Ketrenos\n\n");
			printf("Valid Command Line Options:\n");
			printf(" -nFileame.ext   [default: FRACTAL.???   ]\n");
			printf(" -iIterations    [default: 4             ]\n");
			printf(" -mMaterials     [default: 1 (ON)        ]\n");
			printf(" -wWaterLevel    [default: 0.40          ]\n");
			printf(" -sSnowLevel     [default: 1.00          ]\n");
			printf(" -vVariable      [default: 2.00          ]\n");
			printf(" -xSize          [default: 200           ]\n");
			printf(" -ySize          [default: 200           ]\n");
			printf(" -zSize          [default: 200           ]\n");
			printf(" -tFileType      [default: 3D Studio .ASC]\n\n");
			printf("Filename.ext consits of any valid DOS filename.  Up to 80 characters\n");
			printf("             may be used to include path etc.  The file written is a\n");
			printf("             3D Studio ASCII Text file and can get quite large.\n\n");
			printf("Iterations   is an integer that can range from 1 to 15.  This is\n");
			printf("             used to determine the number of splits performed.\n\n");
			printf("Materials    is used to determine whether or not materials will\n");
			printf("             assigned to faces or not.  1=ON 0=OFF.\n\n");
			printf("<< Press any key to continue >>");
			if (getch()==27)
			{
				printf("\r                               \r");
				exit(0);
			}
			printf("\r                               \r");
			printf("WaterLevel   is the percentage of the landform to make below the SEA\n");
			printf("             LEVEL.  All land below this will be leveled to SEA.  It\n");
			printf("             is entered as a decimal.  (1.00=All .. 0.25=1/4 etc.)\n\n");
			printf("SnowLevel    is the percentage of the landform to make below the SNOW\n");
			printf("             LEVEL.  All land above this will be WHITE.  This makes no\n");
			printf("             plateau adjustments.  (1.00=All .. 0.25=1/4 etc.)\n\n");
			printf("Variable     is the variable degredation of variance.  Basically, what\n");
			printf("             this does is determine how much the variance will decrease\n");
			printf("             with every land split.  Variable>1 will model \"life\".\n");
			printf("             0<Variable<=1 will resemble \"chaos\".  Decent values can\n");
			printf("             be found between 2.00 and 5.00.\n\n");
			printf("Size         is the length of the box containing the landscape along\n");
			printf("             perspective axis (X, Y, or Z).  It is better to keep the\n");
			printf("             values semi-large (in the hundreds) to keep from having\n");
			printf("             distortions due to round-off errors.\n\n");
			printf("<< Press any key to continue >>");
			if (getch()==27)
			{
				printf("\r                               \r");
				exit(0);
			}
			printf("\r                               \r");
			printf("Type         is the filetype to create.  Types are:\n");
			printf("             0 - 3D Studio .ASC [default]\n");
			printf("             1 - Lord Logics Landscape Data Mesh File .INC\n");
			printf("                 Note: Iterations = 8, ZSize = 256\n");
			printf("                       XSize = 256, and YSize = 256\n");
			printf("                       Materials are OFF,\n");
			printf("                       Snow is OFF Water is at 0.35\n\n");
			printf("Any questions, comments, suggestions, donations, or information is welcome.\n");
			printf("Mail to:\n\n");
			printf("                James P. Ketrenos\n");
			printf("                885 S.W. 84th Ct.\n");
			printf("                Portland, OR  97225\n\n");
			printf("Or e-mail at:  ketrenoj@ucs.orst.edu  up till 06-01-93.\n\n");
			printf("If you would like to see the data output to a different file format\n");
			printf("besides the 3D Studio ASCII file, then please send me a note saying\n");
			printf("so along with a description of the file format and how it is made up.\n");
			printf("Primarily I need to know how to define vertices and triangle faces.\n");
			exit(0);
		}

		switch(argv[count1][1]<'a' ? (argv[count1][1]-'A'+'a') : argv[count1][1])
		{
		case    'n':strcpy(filename,&argv[count1][2]); break;
		case    'i':ITER=atoi(&argv[count1][2]); break;
		case    'm':MATERIAL=atoi(&argv[count1][2]); break;
		case    'w':SEA=atof(&argv[count1][2]); break;
		case    's':SNOW=atof(&argv[count1][2]); break;
		case    'v':VARI_CHANGE=atof(&argv[count1][2]); break;
		case    'x':XSIZE=atoi(&argv[count1][2]); break;
		case    'y':YSIZE=atoi(&argv[count1][2]); break;
		case    'z':ZSIZE=atoi(&argv[count1][2]); break;
		case    't':FTYPE=atoi(&argv[count1][2]); break;
		default:argv[count1][0]='?';
			count1--;
		}
	}

	if (filename[0]==0)
		switch(FTYPE)
		{
		case 0:strcpy(filename,"FRACTAL.ASC"); break;
		case 1:strcpy(filename,"FRACTAL.INC"); break;
		}

	if (FTYPE==1)
	{
		MATERIAL=0;
		SEA=0.35;
		SNOW=1.00;
		ITER=8;
		ZSIZE=256;
		XSIZE=YSIZE=256;
	}

	printf("-=[      Fractal Landscape Creator      ]=-\n");
	printf("           -=[ Version  1.5 ]=-\n\n");
	printf("[         - Fractal Parameters -          ]\n");
	printf("[ Matrix Splits         :    %-5u        ]",ITER);
	if ((ITER>0) && (ITER<16))
		printf("\n");
	else
	{
		printf(" Invalid range!\n");
		exit(-1);
	}
	printf("[ Matrix Base           :    %-4lu by %-4lu ]\n",SIZE,SIZE);
	printf("[ Matrix Sea Level      :    %-4.2f         ]",SEA);
	if ((SEA>=0.0) && (SEA<=1.0))
		printf("\n");
	else
	{
		printf(" Invalid range!\n");
		exit(-1);
	}
	printf("[ Matrix Snow Level     :    %-4.2f         ]",SNOW);
	if ((SNOW>=0.0) && (SNOW<=1.0))
		printf("\n");
	else
	{
		printf(" Invalid range!\n");
		exit(-1);
	}
	printf("[ Variance Degredation  :    %-5.2f        ]",VARI_CHANGE);
	if (VARI_CHANGE>0.0)
		printf("\n");
	else
	{
		printf(" Invalid range!\n");
		exit(-1);
	}
	printf("[ Maximum Variance      :    %-7.2f      ]\n",VARI);
	printf("[ Surface Vertices      :    %-8lu     ]\n",buf_size=SIZE*SIZE);
	if (FTYPE!=1)
	printf("[ Surface Faces         :    %-8lu     ]\n",faces=((SIZE-1)*(SIZE-1)*2));
	printf("[ Cube Containment Size :(%-4ux%-4ux%-4u) ]",XSIZE,YSIZE,ZSIZE);
	if ((XSIZE<=0.0) || (YSIZE<=0.0) || (ZSIZE<=0.0))
	{
		printf(" Invalid range!\n");
		exit(-1);
	}
	printf("\n\n");

	printf("[      - Fractal Creation Progress -      ]\n");
	printf("[ Initializing Matrix   :    WAIT.        ]");
	if ((map=(float huge *)halloc(buf_size,sizeof(map[0])))==0)
	{
		printf(" Error!\n");
		printf("          - Insufficient Memory -\n");
		exit(-1);
	}
	for (count1=0; count1<buf_size; count1++)
		map[count1]=(float)987;

	/* Initialize the four corners  */
	srand((unsigned)time(0));       // Initialize the RNG
	map[0*SIZE+0]=(float)((float)RAND_FNC/RAND_MAX) * VARI;
	map[0*SIZE+(SIZE-1)]=(float)((float)RAND_FNC/RAND_MAX) * VARI;
	map[(SIZE-1)*SIZE+(SIZE-1)]=(float)((float)RAND_FNC/RAND_MAX) * VARI;
	map[(SIZE-1)*SIZE+0]=(float)((float)RAND_FNC/RAND_MAX) * VARI;

	printf("\r[ Initializing Matrix   :     OK.         ]\n");
	printf("[ Creating Landscape    :    WAIT.        ]");
	iterate(0,0,SIZE-1,SIZE-1,(float)VARI,map);
	min=map[0];
	max=map[0];
	for (count1=1; count1<buf_size; count1++)
	{
		if (map[count1]<min) min=map[count1];
		if (map[count1]>max) max=map[count1];
	}
	altitude=max-min;
	printf("\r[ Creating Landscape    :     OK.         ]\n");
	printf("[ Adding Elements       :    WAIT.        ]");
	water=(float)altitude*SEA+min;
	snow=(float)altitude*SNOW+min;
	if (altitude==0.0)
	{
		printf(" Error!\n");
		printf("No Landmass present.\n");
		free(map);
		exit(-2);
	}

	for (count1=0; count1<buf_size; count1++)
		if (map[count1]<=water)
			map[count1]=water;

	printf("\r[ Adding Elements       :     OK.         ]\n\n");

	printf("[ Initializing Mesh File:    WAIT.        ]");
	if ((handle=init_file(filename,FTYPE))==0)
	{
		printf("\r[ Initializing Mesh File:    ERROR!!      ]\n");
		free(map);
		exit(-1);
	}
	if (strlen(filename)>12)
		printf("\r[ Initializing Mesh File: ...%-12s ]\n",&filename[strlen(filename)-12]);
	else
		printf("\r[ Initializing Mesh File:   %-12s  ]\n",filename);



	printf("[ Writing Vertices      :    WAIT.        ]");
	if (write_verts(handle, FTYPE)==0)
		printf("\r[ Writing Vertices      :     OK.         ]\n");
	else
	{
		printf("\r[ Writing Vertices      :    ERROR!       ]\n");
		close(handle);
		free(map);
		exit(-1);
	}

	printf("[ Writing Faces         :    WAIT.        ]");
	if (write_faces(handle, FTYPE)==0)
		printf("\r[ Writing Faces         :     OK.         ]\n");
	else
	{
		printf("\r[ Writing Faces         :    ERROR!       ]\n");
		close(handle);
		free(map);
		exit(-1);
	}

	printf("[ Closing Mesh File     :    WAIT.        ]");
	fclose(handle);
	printf("\r[ Closing Mesh File     :     OK.         ]\n");
	free(map);
}

void iterate(long c1, long c2, long c3, long c4, float variance, float huge *map)
{
long    longi;
long    latit;
float   height;
float   change;

	if ((c3 - (c1 + 1)) & 1)
		change=0.5;
	else
		change=0.0;

	longi=((c1 + c3) / 2);
	latit=((c2 + c4) / 2);

	if (map[c2*SIZE+longi]==987)
	{
		height=((map[c2*SIZE+c1] + map[c2*SIZE+c3]) / 2);
		height+=(float)((float)RAND_FNC/RAND_MAX) * variance - (variance * 0.5);
		map[c2*SIZE+longi]=height+((map[c2*SIZE+c1]-height)*change)/((longi+change)-c1);
	}

	if (map[c4*SIZE+longi]==987)
	{
		height=((map[c4*SIZE+c1] + map[c4*SIZE+c3]) / 2);
		height+=(float)((float)RAND_FNC/RAND_MAX) * variance - (variance * 0.5);
		map[c4*SIZE+longi]=height+((map[c4*SIZE+c1]-height)*change)/((longi+change)-c1);
	}

	if (map[latit*SIZE+c1]==987)
	{
		height=((map[c2*SIZE+c1] + map[c4*SIZE+c1]) / 2);
		height+=(float)((float)RAND_FNC/RAND_MAX) * variance - (variance * 0.5);
		map[latit*SIZE+c1]=height+((map[c2*SIZE+c1]-height)*change)/((latit+change)-c2);
	}

	if (map[latit*SIZE+c3]==987)
	{
		height=((map[c2*SIZE+c3] + map[c4*SIZE+c3]) / 2);
		height+=(float)((float)RAND_FNC/RAND_MAX) * variance - (variance * 0.5);
		map[latit*SIZE+c3]=height+((map[c2*SIZE+c3]-height)*change)/((latit+change)-c2);
	}

	height=((map[c2*SIZE+c1] + map[c2*SIZE+c3] + map[c4*SIZE+c1] + map[c4*SIZE+c3] +
		map[c2*SIZE+longi] + map[c4*SIZE+longi] + map[latit*SIZE+c1] + map[latit*SIZE+c3]) / 8);
	height+=(float)((float)RAND_FNC/RAND_MAX) * variance - (variance * 0.5);

	if (change==0.5)
		map[latit*SIZE+longi]=height+((map[c2*SIZE+c1]-height)*0.7071)/(1.4142*((longi+change)-c1));
	else
		map[latit*SIZE+longi]=height;

	if ((longi==c1) || (longi==c3) || (latit==c2) || (latit==c4)) return;

	iterate(c1, c2, longi, latit, (float)((longi-c1)*variance)/(((c3-c1)*VARI_CHANGE)/2), map);
	iterate(longi, c2, c3, latit, (float)((c3-longi)*variance)/(((c3-c1)*VARI_CHANGE)/2), map);
	iterate(c1, latit, longi, c4, (float)((latit-c2)*variance)/(((c4-c2)*VARI_CHANGE)/2), map);
	iterate(longi, latit, c3, c4, (float)((c4-latit)*variance)/(((c4-c2)*VARI_CHANGE)/2), map);
	return;
}

void write_material(FILE *handle,unsigned long c1, unsigned long c2, unsigned long c3,float huge *map,
	float water, float snow, float altitude)
{
float   average;

	average=(map[c1] + map[c2] + map[c3]) / 3;

	if (average >= snow)
		fprintf(handle,"Material:\"%s\"\n",SNOW_MATERIAL);
	else
	if ((map[c1]==water) && (map[c2]==water) && (map[c3]==water))
		fprintf(handle,"Material:\"%s\"\n",WATER_MATERIAL);
	else
	{
		if ( ((fabs(map[c1]-average)*(ZSIZE/altitude)*2*SIZE/YSIZE)>4.5) ||
		     ((fabs(map[c2]-average)*(ZSIZE/altitude)*2*SIZE/YSIZE)>4.5) ||
		     ((fabs(map[c3]-average)*(ZSIZE/altitude)*2*SIZE/XSIZE)>4.5))
			fprintf(handle,"Material:\"%s\"\n",ROCK_MATERIAL);
		else
			fprintf(handle,"Material:\"%s\"\n",GRASS_MATERIAL);
	}
}
