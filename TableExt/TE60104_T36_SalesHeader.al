tableextension 60104 FBM_SalesHeaderExt_CO extends "Sales Header"
{
    fields
    {

        field(70006; "FBM_Cust Payment Bank Code2"; Code[100])
        {

            FieldClass = "Flowfield";
            CalcFormula = lookup(Customer."FBM_Payment Bank Code2" where("No." = field("Sell-to Customer No.")));
        }


        field(70011; "FBM_Cust Payment Bank Code"; Code[100])
        {

            FieldClass = "Flowfield";
            CalcFormula = lookup(Customer."FBM_Payment Bank Code2" where("No." = field("Sell-to Customer No.")));
        }







    }


}