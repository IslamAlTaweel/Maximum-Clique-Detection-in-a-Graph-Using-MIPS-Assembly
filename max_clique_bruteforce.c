//maximum clique brute force implementation in C (Source: geeksforgeeks) 

#include <stdio.h>
#include <stdlib.h>

#define MAX_VERTICES 100

// Array to store the current subset of vertices being checked
int currentSubset[MAX_VERTICES];

// Number of vertices in the graph
int numVertices;

// Adjacency matrix representing the graph
int adjacencyMatrix[MAX_VERTICES][MAX_VERTICES];

// Degree of each vertex (optional, can be used for heuristics)
int vertexDegree[MAX_VERTICES];

// Helper function to return the maximum of two integers
int max(int a, int b)
{
    return (a > b) ? a : b;
}

// Function to check if the vertices in currentSubset form a clique
// 'subsetSize' is the number of vertices in the subset
int isClique(int subsetSize)
{
    for (int i = 1; i < subsetSize; i++)
    {
        for (int j = i + 1; j < subsetSize; j++)
        {
            // If there is no edge between any pair of vertices, it's not a clique
            if (adjacencyMatrix[currentSubset[i]][currentSubset[j]] == 0)
                return 0; // Not a clique
        }
    }
    return 1; // All pairs are connected -> clique
}

// Recursive function to find the size of the largest clique
// 'lastVertex' is the index of the last vertex added to currentSubset
// 'currentSize' is the number of vertices currently in currentSubset
int findMaxClique(int lastVertex, int currentSize)
{
    int maxSizeFound = 0;

    // Try to add each remaining vertex to the current subset
    for (int nextVertex = lastVertex + 1; nextVertex <= numVertices; nextVertex++)
    {
        currentSubset[currentSize] = nextVertex; // Add vertex to subset

        // Only proceed if the new subset is still a clique
        if (isClique(currentSize + 1))
        {
            // Update maximum clique size found so far
            maxSizeFound = max(maxSizeFound, currentSize);

            // Recursively try to add more vertices
            maxSizeFound = max(maxSizeFound, findMaxClique(nextVertex, currentSize + 1));
        }
    }
    return maxSizeFound;
}

int main()
{
    // List of edges (1-based indexing)
    int edges[][2] =
    {
        {1, 2}, {2, 3}, {3, 1},
        {4, 3}, {4, 1}, {4, 2}
    };
    int numEdges = sizeof(edges) / sizeof(edges[0]);

    numVertices = 4; // Number of vertices in the graph

    // Initialize adjacency matrix and vertex degrees
    for (int i = 0; i < numVertices + 1; i++)
    {
        for (int j = 0; j < numVertices + 1; j++)
        {
            adjacencyMatrix[i][j] = 0;
        }
        vertexDegree[i] = 0;
    }

    // Populate adjacency matrix based on the edges
    for (int i = 0; i < numEdges; i++)
    {
        int u = edges[i][0];
        int v = edges[i][1];

        adjacencyMatrix[u][v] = 1;
        adjacencyMatrix[v][u] = 1;

        vertexDegree[u]++;
        vertexDegree[v]++;
    }

    // Find and print the size of the maximum clique
    int maxCliqueSize = findMaxClique(0, 1);
    printf("Maximum clique size: %d\n", maxCliqueSize);

    return 0;
}
