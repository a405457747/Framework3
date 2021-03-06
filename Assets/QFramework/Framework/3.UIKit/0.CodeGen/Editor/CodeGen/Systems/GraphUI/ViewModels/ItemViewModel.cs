using System;
using System.Linq;
using QFramework.CodeGen;
using Invert.Data;
using UnityEngine;

namespace QFramework.CodeGen
{
    public class ItemViewModel : GraphItemViewModel
    {
        private bool _isEditable = true;

        public ItemViewModel(DiagramNodeViewModel nodeViewModel)
        { 
            NodeViewModel = nodeViewModel;
        }


        public override bool Enabled
        {
            get { return this.NodeViewModel.Enabled; }
        }

        public DiagramNodeViewModel NodeViewModel { get; set; }
        public IDiagramNodeItem NodeItem
        {
            get { return (IDiagramNodeItem)DataObject; }
        }

        public override string Name
        {
            get { return NodeItem.Name; }
            set { NodeItem.Name = value; }
        }

        public virtual Vector2 Position { get; set; }

        public virtual bool IsEditing
        {
            get { return NodeItem.IsEditing; }
            set
            {
                NodeItem.IsEditing = value;
                IsDirty = true;
            }
        }

        public override void RecordInserted(IDataRecord record)
        {
            base.RecordInserted(record);
            if (record.IsNear(DataObject as IDataRecord))
            {
            }
        }

        public override void RecordRemoved(IDataRecord record)
        {
            base.RecordRemoved(record);
            if (record.IsNear(DataObject as IDataRecord))
            {
            }
        }

        //public override Func<IDiagramNodeItem, IDiagramNodeItem, bool> InputValidator
        //{
        //    get
        //    {
        //        var item = DataObject as IDiagramNodeItem;
        //        item.ValidateInput;
        //    }
        //}

        public override ConnectorViewModel InputConnector
        {
            get
            {

                return base.InputConnector;
            }
        }

        public override ConnectorViewModel OutputConnector
        {
            get
            {
                return base.OutputConnector;
            }
        }

        public virtual bool IsEditable
        {
            get { return _isEditable; }
            set { _isEditable = value; }
        }


        public string Highlighter { get; set; }

        public virtual bool AllowRemoving
        {
            get { return true; }
        }

        public virtual string Label
        {
            get { return Name; }
        }

        public void Rename(string newName)
        {
            NodeItem.Rename(NodeItem.Node, newName);
        }

        string editText = null;
        public void BeginEditing()
        {
            editText = Name;
            
            IsEditing = true;
        }
        public override void OnDeselected()
        {
            base.OnDeselected();
            if (IsEditing) EndEditing();
        }

        public void EndEditing()
        {
            if (!IsEditing) return;
            IsEditing = false;
            InvertApplication.SignalEvent<INodeItemEvents>(_ => _.Renamed(NodeItem,editText,NodeItem.Name));
        }
        public override bool IsSelected
        {
            get
            {
                return base.IsSelected;
            }
            set
            {
                if (!value)
                {
                     EndEditing();
                }
                base.IsSelected = value;
            }
        }
        
        public override void Select()
        {
            if (IsSelected) return;
            var items = NodeViewModel.DiagramViewModel.SelectedNodeItems.ToArray();
            foreach (var item in items)
                item.IsSelected = false;
#if UNITY_EDITOR
            GUIUtility.keyboardControl = 0;
#endif
            NodeViewModel.Select();
            IsSelected = true;
            InvertApplication.SignalEvent<IGraphSelectionEvents>(_ => _.SelectionChanged(this));
            //BeginEditing();
        }
    }
}