/*
** 	This class is used in BatchUpdateSubjectToArchived
**  created by Sergii Korolivskyi at 11/02/2020
*/
global class AggregateResultIterable implements Iterable<AggregateResult> {
    private String query;
    
    global AggregateResultIterable(String soql){
        query = soql;
    }
    
    
    global Iterator<AggregateResult> Iterator(){
        return new AggregateResultIterator(query);
    }
}