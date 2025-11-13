#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_VERTICES 5

// Array to store the current subset of vertices being checked
int currentSubset[MAX_VERTICES];

// Number of vertices in the graph
int numVertices;

// Adjacency matrix representing the graph
int adjacencyMatrix[MAX_VERTICES][MAX_VERTICES];

// Degree of each vertex (optional, can be used for heuristics)
int vertexDegree[MAX_VERTICES];

// Store the best clique found
int maxCliqueSubset[MAX_VERTICES];
int maxCliqueSizeGlobal = 0;

// Helper function to return the maximum of two integers
int max(int a, int b)
{
    return (a > b) ? a : b;
}

// Function to check if the vertices in currentSubset form a clique
// 'subsetSize' is the number of vertices in the subset
int isClique(int subsetSize)
{
    for (int i = 0; i < subsetSize; i++)
    {
        for (int j = i + 1; j < subsetSize; j++)
        {
            // If there is no edge between any pair of vertices, it's not a clique
            if (adjacencyMatrix[currentSubset[i]][currentSubset[j]] == 0)
                return 0;
        }
    }
    return 1; // All pairs are connected -> clique
}

// Recursive function to find the size of the largest clique
// 'lastVertex' is the index of the last vertex added to currentSubset
// 'currentSize' is the number of vertices currently in currentSubset
int findMaxClique(int lastVertex, int currentSize)
{
    int maxSizeFound = currentSize;

    // Update global best clique if current clique is bigger
    if (currentSize > maxCliqueSizeGlobal)
    {
        maxCliqueSizeGlobal = currentSize;
        for (int i = 0; i < currentSize; i++)
            maxCliqueSubset[i] = currentSubset[i];
    }

    // Try to add each remaining vertex to the current subset
    for (int nextVertex = lastVertex + 1; nextVertex < numVertices; nextVertex++)
    {
        currentSubset[currentSize] = nextVertex; // Add vertex to subset

        // Only proceed if the new subset is still a clique
        if (isClique(currentSize + 1))
        {
            // Recursively try to add more vertices
            maxSizeFound = max(maxSizeFound, findMaxClique(nextVertex, currentSize + 1));
        }
    }

    return maxSizeFound;
}

// Load adjacency matrix from file
// Checks for valid n x n matrix, 0/1 entries, and detects missing numbers
void load_file(char filename[])
{
    FILE *fpt_in = fopen(filename, "r");
    if (!fpt_in)
    {
        printf("Error: Could not open file '%s'\n", filename);
        exit(1);
    }

    char line[1024];
    int cnt = 0;               // Row counter
    int expectedColumns = -1;  // Expected number of columns per row

    // Skip the header row (column labels)
    if (!fgets(line, sizeof(line), fpt_in))
    {
        printf("Error: Empty file.\n");
        fclose(fpt_in);
        exit(1);
    }

    // Read each data row
    while (fgets(line, sizeof(line), fpt_in))
    {
        int j = 0; // Column index

        // Remove trailing newline
        int len = strlen(line);
        if (len > 0 && line[len - 1] == '\n')
            line[len - 1] = '\0';

        char *token = strtok(line, " "); // First token is row label
        if (!token)
        {
            printf("Error: Row %d is empty\n", cnt);
            fclose(fpt_in);
            exit(1);
        }

        // Skip row label
        token = strtok(NULL, " ");
        while (token)
        {
            adjacencyMatrix[cnt][j] = atoi(token);

            // Check for valid adjacency entry (0 or 1)
            if (adjacencyMatrix[cnt][j] != 0 && adjacencyMatrix[cnt][j] != 1)
            {
                printf("Error: Invalid entry at row %d, column %d (must be 0 or 1)\n", cnt, j);
                fclose(fpt_in);
                exit(1);
            }

            j++;
            token = strtok(NULL, " ");
        }

        // Set expected number of columns from first row
        if (expectedColumns == -1)
        {
            expectedColumns = j;
        }
        // Ensure current row matches expected number of columns
        else if (j != expectedColumns)
        {
            printf("Error: Row %d has %d columns, expected %d\n", cnt, j, expectedColumns);
            fclose(fpt_in);
            exit(1);
        }

        cnt++;
    }

    // Final check: ensure it’s n × n
    if (cnt != expectedColumns)
    {
        printf("Error: Invalid adjacency matrix (not n × n)\n");
        fclose(fpt_in);
        exit(1);
    }

    numVertices = cnt; // Set global vertex count
    fclose(fpt_in);
}
int main()
{
    char inputFile[50];
    char outputFile[50];

    // Prompt user to enter input and output file names
    printf("Enter adjacency matrix input file name: ");
    scanf("%s", inputFile);

    printf("Enter output file name: ");
    scanf("%s", outputFile);

    // Load adjacency matrix from file
    load_file(inputFile);

    // Find the maximum clique
    int maxCliqueSize = 0;
    for (int i = 0; i < numVertices; i++)
    {
        currentSubset[0] = i; // Start clique with vertex i
        maxCliqueSize = max(maxCliqueSize, findMaxClique(i, 1));
    }

    // Open output file
    FILE *fpt_out = fopen(outputFile, "w");
    if (!fpt_out)
    {
        printf("Error: Could not open output file '%s'\n", outputFile);
        return 1;
    }

    // Output the result to console and file
    if (maxCliqueSizeGlobal == 0)
    {
        printf("No clique found in the graph.\n");
        fprintf(fpt_out, "No clique found in the graph.\n");
    }
    else
    {
        printf("Maximum clique size: %d\n", maxCliqueSizeGlobal);
        fprintf(fpt_out, "Maximum clique size: %d\n", maxCliqueSizeGlobal);

        printf("Vertices in the clique: ");
        fprintf(fpt_out, "Vertices in the clique: ");

        for (int i = 0; i < maxCliqueSizeGlobal; i++)
        {
            printf("%d ", maxCliqueSubset[i]); // Print 0-based vertex labels
            fprintf(fpt_out, "%d ", maxCliqueSubset[i]);
        }
        printf("\n");
        fprintf(fpt_out, "\n");
    }

    fclose(fpt_out); // Close the output file
    return 0;
}
