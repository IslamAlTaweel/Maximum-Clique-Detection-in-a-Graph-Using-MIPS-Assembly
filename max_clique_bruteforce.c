#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_VERTICES 5

int currentSubset[MAX_VERTICES];
int numVertices;
int adjacencyMatrix[MAX_VERTICES][MAX_VERTICES];
int vertexDegree[MAX_VERTICES];

int max(int a, int b)
{
    return (a > b) ? a : b;
}

int isClique(int subsetSize)
{
    for (int i = 0; i < subsetSize; i++)
    {
        for (int j = i + 1; j < subsetSize; j++)
        {
            if (adjacencyMatrix[currentSubset[i]][currentSubset[j]] == 0)
                return 0;
        }
    }
    return 1;
}

int findMaxClique(int lastVertex, int currentSize)
{
    int maxSizeFound = currentSize;

    for (int nextVertex = lastVertex + 1; nextVertex < numVertices; nextVertex++)
    {
        currentSubset[currentSize] = nextVertex;
        if (isClique(currentSize + 1))
        {
            maxSizeFound = max(maxSizeFound, findMaxClique(nextVertex, currentSize + 1));
        }
    }

    return maxSizeFound;
}

void load_file(char filename[]) {
    FILE *fpt_in = fopen(filename, "r");
    if (!fpt_in) {
        printf("Error: Could not open file '%s'\n", filename);
        exit(1);
    }

    int num_Vertices_in_Rows[MAX_VERTICES];
    int num_Vertices_in_columns = 0;
    char line[1024];
    int cnt = 0;

    // Skip the header row (column labels)
    if (!fgets(line, sizeof(line), fpt_in)) {
        printf("Error: Empty file.\n");
        fclose(fpt_in);
        exit(1);
    }

    // Read each data row
    while (fgets(line, sizeof(line), fpt_in)) {
        int numVerticesRow = 0;
        int labeltoken = 1; // first token is row label
        char *token = strtok(line, " ");
        int j = 0; // column index

        while (token) {
            if (labeltoken) {
                // skip row label
                labeltoken = 0;
            } else {
                adjacencyMatrix[cnt][j] = atoi(token);
                if (adjacencyMatrix[cnt][j] != 0 && adjacencyMatrix[cnt][j] != 1) {
                    printf("Error: Invalid entry at row %d, column %d (must be 0 or 1)\n", cnt, j);
                    fclose(fpt_in);
                    exit(1);
                }
                j++;
                numVerticesRow++;
            }
            token = strtok(NULL, " ");
        }

        // Record number of vertices (columns) in this row
        if (numVerticesRow <= 0 || numVerticesRow > MAX_VERTICES) {
            printf("Error: Invalid number of vertices in row %d: %d\n", cnt, numVerticesRow);
            fclose(fpt_in);
            exit(1);
        }

        // ensure each row has same number of columns as first row
        if (cnt > 0 && numVerticesRow != num_Vertices_in_Rows[0]) {
            printf("Error: Inconsistent number of columns in row %d (expected %d, got %d)\n",
                   cnt, num_Vertices_in_Rows[0], numVerticesRow);
            fclose(fpt_in);
            exit(1);
        }

        num_Vertices_in_Rows[cnt] = numVerticesRow;
        num_Vertices_in_columns++;
        cnt++;
    }

    // ensure it's n × n
    for (int i = 0; i < cnt; i++) {
        if (num_Vertices_in_Rows[i] != num_Vertices_in_columns) {
            printf("Error: Invalid adjacency matrix (not n × n)\n");
            fclose(fpt_in);
            exit(1);
        }
    }

    numVertices = cnt; // set global vertex count

    fclose(fpt_in);
}


int main()
{
    char filename[50];
    printf("Enter adjacency matrix file name: ");
    scanf("%s", filename);

    load_file(filename);

    int maxCliqueSize = 0;
    for (int i = 0; i < numVertices; i++)
    {
        currentSubset[0] = i;
        maxCliqueSize = max(maxCliqueSize, findMaxClique(i, 1));
    }

    printf("Maximum clique size: %d\n", maxCliqueSize);

    return 0;
}
