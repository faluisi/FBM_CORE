

report 60126 FBM_SalesReportNotPosted_CO
{
    DefaultLayout = RDLC;
    //UsageCategory = Administration;
    RDLCLayout = './RDLC/OnetechSalesReportNotPosted.rdl';
    ApplicationArea = All;
    Caption = 'Sales Report Not Posted';

    dataset
    {

        dataitem(salesinvoiceline; "Sales Line")
        {
            RequestFilterFields = "Posting Date", "Sell-to customer no.";

            column(invpostingdate; format(invheader."Posting Date"))
            {

            }
            column(filters; filters)
            {

            }
            column(doctype; invheader."Document Type")
            {

            }

            column(compname; compinfo.Name)
            {

            }
            column(invdocumentno; "Document No.")
            {

            }
            column(invNo; "No.")
            {

            }
            column(invDescr; "Description")
            {

            }
            column(invGenBUsPost; "Gen. Bus. Posting Group")
            {

            }
            column(invenProd; "Gen. Prod. Posting Group")
            {

            }
            column(invamount; "Amount")
            {

            }
            column(invperiodstart; format("FBM_Period Start"))
            {

            }
            column(invperiodend; format("FBM_Period End"))
            {

            }
            column(invglaccountname; invglaccountname)
            {

            }

            column(invContract; invContract)
            {

            }
            column(invsite; invsite)
            {

            }

            trigger OnPreDataItem()
            begin
                SetFilter("Document Type", 'Invoice|Credit Memo');
                filters := salesinvoiceline.GetFilters();
                if (filters <> '') then begin

                end;
                compinfo.get();
            end;

            trigger OnAfterGetRecord()


            var
                myInt: Integer;

            begin
                invsite := '';
                invContract := '';
                invglaccountname := '';
                invheader.SetRange("No.", salesinvoiceline."Document No.");
                if invheader.FindFirst() then begin
                    invsite := invheader.FBM_Site;
                    invContract := invheader."FBM_Contract Code";
                end;
                if glaccount.Get("No.") then begin
                    invglaccountname := glaccount.Name;
                end;

            end;

        }


    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    //field(Name; SourceExpression)
                    // {
                    //    ApplicationArea = All;

                    // }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(ActionName)
                {
                    ApplicationArea = All;

                }
            }
        }
    }

    var
        invheader: Record "Sales Header";

        invsite: Code[50];
        invContract: Code[50];
        glaccount: Record "G/L Account";
        invglaccountname: Text;
        filters: Text;

        compinfo: Record "Company Information";

        crmemosite: Code[50];
        crmemoContract: Code[50];
        crmemoglaccountname: Text;
}