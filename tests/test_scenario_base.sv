`ifndef __test_scenario_base__
`define __test_scenario_base__

class test_scenario_base;

    static local test_scenario_base tests[string];

    string test_name;

    function new( string name = "" );
        tests[name] = this;
    endfunction

    virtual task execute();
    endtask

    virtual task run_tests();
        if( $value$plusargs("test_name=%s", this.test_name) )begin
            if( tests.exists(test_name) )begin
                tests[test_name].execute();
            end else begin
                $display("No test object");
            end
        end else begin
        end
    endtask

endclass

`endif