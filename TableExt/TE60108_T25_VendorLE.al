tableextension 60108 FBM_VendorLEExt_CO extends "Vendor Ledger Entry"
{
    fields
    {

        field(70200; "FBM_Default Bank Account_FF"; Code[20])
        {
            TableRelation = "Bank Account";
            Caption = 'Default Bank Account';

            FieldClass = FlowField;
            CalcFormula = lookup(Vendor."FBM_Default Bank Account" where("No." = field("Vendor No.")));
        }

    }
}
