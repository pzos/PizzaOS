#include <memorymanagement.h>

using namespace myos;
using namespace myos::common;


        
MemoryManager* MemoryManager::activeMemoryManager = 0;

        

MemoryManager::MemoryManager(common::size_t first, common::size_t size)
{
    activeMemoryManager = this;
    
    if(size < sizeof(MemoryChunk))
    {
        firstchunk = 0;
    }
    else
    {
        firstchunk = (MemoryChunk*)first;
        firstchunk->allocated = false;
        firstchunk->size = size - sizeof(MemoryChunk);
        firstchunk->next = 0;
        firstchunk->prev = 0;
    }
}

MemoryManager::~MemoryManager()
{
}
     
void* MemoryManager::malloc(common::size_t size)
{
    
    MemoryChunk *result = 0;
    
    for(MemoryChunk* chunk = firstchunk; (result == 0) && (chunk != 0); chunk = chunk->next)
        if((!chunk->allocated) && chunk->size >= size)
            result = chunk;
    
    if(result == 0)
        return 0;
    
    
    if(result->size < size + sizeof(MemoryChunk) + 1)
    {
        result->allocated = true;
    }
    else
    {
        
        MemoryChunk* temp = (MemoryChunk*)(((size_t)result) + sizeof(MemoryChunk) + size);
        
        temp->allocated = false;
        temp->size = result->size - size - sizeof(MemoryChunk);
        temp->prev = result;
        temp->next = result->next;
        
        result->allocated = true;
        result->size = size;
        result->next = temp;
        
    }
    
    
    return (void*)(((size_t)result) + sizeof(MemoryChunk));
}


void MemoryManager::free(void* ptr)
{
    MemoryChunk* chunk = (MemoryChunk*)(((size_t)ptr) - sizeof(MemoryChunk));
    
    chunk->allocated = false;
    
    if(chunk->prev != 0 && !chunk->prev->allocated)
    {
        chunk->prev->next = chunk->next;
        chunk->prev->size += chunk->size + sizeof(MemoryChunk);
        if(chunk->next != 0)
            chunk->next->prev = chunk->prev;
        
        chunk = chunk->prev;
    }
    
    if(chunk->next != 0 && !chunk->next->allocated)
    {
        chunk->size += chunk->next->size + sizeof(MemoryChunk);
        chunk->next = chunk->next->next;
        if(chunk->next != 0)
            chunk->next->prev = chunk;
    }
    
    
}





void* operator new(unsigned size)
{
    return MemoryManager::activeMemoryManager->malloc(size);
}

void* operator new[](unsigned size)
{
    return MemoryManager::activeMemoryManager->malloc(size);
}
// placement new
void* operator new(myos::common::size_t size, void *ptr)
{
    return ptr;
}

void* operator new[](myos::common::size_t size, void *ptr)
{
    return ptr;
}

void operator delete(void* ptr)
{
    MemoryManager::activeMemoryManager->free(ptr);
}

void operator delete[](void* ptr)
{
    MemoryManager::activeMemoryManager->free(ptr);
}