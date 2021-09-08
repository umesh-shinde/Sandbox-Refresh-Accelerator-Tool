public class BatchofSandboxes implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts {
    public string metadata;
    public String[] start(Database.BatchableContext context) {
        return IntSandbox_Info.getsandboxNames();
    }
    public void Execute(Database.BatchableContext context,List<String> listofsandboxNames){
        System.debug('listofsandboxNames list'+listofsandboxNames);
        Set<String> setofSandboxNames = new Set<String>(listofsandboxNames);
        Integer size=setofSandboxNames.size();
        metadata = '{"Metadata":{"customValue":[';
        for(String sandbox:setofSandboxNames){
            System.debug('listofsandboxNames list'+sandbox);
            String label=sandbox;
            if(size>1){
                System.debug('if'+size);
                metadata+='{"color":null,"default":false,"description":null,"isActive":null,"label":"'+label+'","urls":null,"valueName":"'+label+'"},';
            }else metadata+='{"color":null,"default":false,"description":null,"isActive":null,"label":"'+label+'","urls":null,"valueName":"'+label+'"}],';
            if(size>0) size-=1;
        }
        metadata+='"description":null,"masterLabel":"NewSandboxes","sorted":false,"urls":null},"FullName":"NewSandboxes"}';
        System.debug('metadata string'+metadata);
    }
    public void finish(Database.BatchableContext context){
        MetadataUtility.updateGlobalPickList('0Nt5e000000V9KkCAK', metadata);
    }
}