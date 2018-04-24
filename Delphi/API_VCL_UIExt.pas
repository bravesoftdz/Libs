unit API_VCL_UIExt;

interface
uses
  VirtualTrees;

type
  TVSTreeHelper = class helper for TVirtualStringTree
  private
    function DoFindNode<T: class>(aParentNode: PVirtualNode; aObject: T): PVirtualNode;
  public
    function FindNode<T: class>(aObject: T): PVirtualNode;
  end;

implementation

function TVSTreeHelper.DoFindNode<T>(aParentNode: PVirtualNode; aObject: T): PVirtualNode;
var
  NodeObject: T;
  VirtualNode: PVirtualNode;
begin
  Result := nil;

  for VirtualNode in ChildNodes(aParentNode) do
    begin
      NodeObject := GetNodeData<T>(VirtualNode);

      if NodeObject = aObject then
        Exit(VirtualNode);

      Result := DoFindNode<T>(VirtualNode, aObject);
    end;
end;

function TVSTreeHelper.FindNode<T>(aObject: T): PVirtualNode;
begin
  Result := DoFindNode<T>(Self.RootNode, aObject);
end;

end.
