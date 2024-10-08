pageextension 60169 FBM_UserSetupExt_CO extends "User Setup"
{
    layout
    {
        addafter("Time Sheet Admin.")
        {
            field("See LCY in Journals"; rec."FBM_See LCY in Journals")
            {
                ApplicationArea = All;
            }

        }
        addafter("Email")
        {
            field("Item Filter"; rec."FBM_Item Filter")
            {
                ApplicationArea = All;
            }

            field("Bank Filter"; rec."FBM_Bank Filter")
            {
                ApplicationArea = All;
            }
            field("Approve Finance"; rec."FBM_Approve Finance")
            {
                ApplicationArea = All;
            }
            field("Approve AP"; rec."FBM_Approve AP")
            {
                ApplicationArea = All;
            }
            field(FBM_Paid_Enabled; Rec.FBM_Paid_Enabled)
            {
                ApplicationArea = All;
            }
            field(FBM_CheckWS; Rec.FBM_CheckWS)
            {
                ApplicationArea = All;
            }
        }
        addlast(Control1)
        {
            field(FBM_EditMaster; Rec.FBM_EditMaster)
            {
                ApplicationArea = All;
            }
        }
    }

}
