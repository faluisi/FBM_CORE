pageextension 60102 FBM_ItemLEExt_CO extends "Item Ledger Entries"
{
    layout
    {
        addafter("Document No.")
        {
            field("Value Entry Document No."; rec."FBM_Document No Value Entry_FF")
            {

            }
        }
        addlast(Control1)
        {
            field(FBM_Site; Rec.FBM_Site)
            {
                ApplicationArea = all;

            }

        }
    }

}