//maximum clique brute force implementation in C (Source: geeksforgeeks) 

#include <stdio.h>
#include <stdlib.h>

#define MAX 100

// Stores the vertices
int store[MAX], n;

// Graph
int graph[MAX][MAX];

// Degree of the vertices
int d[MAX];

// Helper function to return max of two integers
int max(int a, int b)
{
    return (a > b) ? a : b;
}

// Function to check if the given set of
// vertices in store array is a clique or not
int is_clique(int b)
{
    int i, j;
    for (i = 1; i < b; i++)
    {
        for (j = i + 1; j < b; j++)
        {
            // If any edge is missing
            if (graph[store[i]][store[j]] == 0)
                return 0;
        }
    }
    return 1;
}

// Function to find all the sizes of maximal cliques
int maxCliques(int i, int l)
{
    int max_ = 0;
    int j;

    for (j = i + 1; j <= n; j++)
    {
        store[l] = j;

        if (is_clique(l + 1))
        {
            max_ = max(max_, l);
            max_ = max(max_, maxCliques(j, l + 1));
        }
    }
    return max_;
}

// Driver code
int main()
{
    int edges[][2] = { {1, 2}, {2, 3}, {3, 1}, {4, 3}, {4, 1}, {4, 2} };
    int size = sizeof(edges) / sizeof(edges[0]);
    int i;

    n = 4;

    for (i = 0; i < size; i++)
    {
        graph[edges[i][0]][edges[i][1]] = 1;
        graph[edges[i][1]][edges[i][0]] = 1;
        d[edges[i][0]]++;
        d[edges[i][1]]++;
    }

    printf("%d\n", maxCliques(0, 1));

    return 0;
}
