`default_nettype none

module chip_top
#(parameter bits_per_cycle = 4)
(
    `ifdef USE_POWER_PINS
    inout  wire VDD,
    inout  wire VSS,
    `endif

    inout  wire clk_PAD,
    inout  wire rst_PAD,
    inout  wire seed_reg_en_PAD,
    inout  wire triv_rst_PAD,
    inout  wire triv_en_PAD,
    inout  wire [3:0] data_in_PAD,
    inout  wire [(bits_per_cycle-1):0] data_out_PAD
);

    wire clk_PAD2CORE;
    wire rst_PAD2CORE;
    wire seed_reg_en_PAD2CORE;
    wire triv_rst_PAD2CORE;
    wire triv_en_PAD2CORE;
    wire [3:0] data_in_PAD2CORE;
    wire [(bits_per_cycle-1):0] data_out_CORE2PAD;

    // Power ground pad instances
    generate
    for (genvar i=0; i<4; i++) begin : dvdd_pads
        (* keep *)
        gf180mcu_fd_io__dvdd pad (
            `ifdef USE_POWER_PINS
            .DVDD   (VDD),
            .DVSS   (VSS),
            .VSS    (VSS)
            `endif
        );
    end
    
    for (genvar i=0; i<4; i++) begin : dvss_pads
        (* keep *)
        gf180mcu_fd_io__dvss pad (
            `ifdef USE_POWER_PINS
            .DVDD   (VDD),
            .DVSS   (VSS),
            .VDD    (VDD)
            `endif
        );
    end
    endgenerate

    // Signal IO pad instances

    // Schmitt trigger for clock pad
    gf180mcu_fd_io__in_s clk_pad (
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
    
        .Y      (clk_PAD2CORE),
        .PAD    (clk_PAD),
        
        .PU     (1'b0),
        .PD     (1'b0)
    );
    
    // Normal inputs
    gf180mcu_fd_io__in_c rst_pad (
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
    
        .Y      (rst_PAD2CORE),
        .PAD    (rst_PAD),
        
        .PU     (1'b0),
        .PD     (1'b0)
    );
    
    gf180mcu_fd_io__in_c seed_reg_en_pad (
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
    
        .Y      (seed_reg_en_PAD2CORE),
        .PAD    (seed_reg_en_PAD),
        
        .PU     (1'b0),
        .PD     (1'b0)
    );
    
    gf180mcu_fd_io__in_c triv_rst_pad (
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
    
        .Y      (triv_rst_PAD2CORE),
        .PAD    (triv_rst_PAD),
        
        .PU     (1'b0),
        .PD     (1'b0)
    );
    
    gf180mcu_fd_io__in_c triv_en_pad (
        `ifdef USE_POWER_PINS
        .DVDD   (VDD),
        .DVSS   (VSS),
        .VDD    (VDD),
        .VSS    (VSS),
        `endif
    
        .Y      (triv_en_PAD2CORE),
        .PAD    (triv_en_PAD),
        
        .PU     (1'b0),
        .PD     (1'b0)
    );

    generate
    for (genvar i=0; i<4; i++) begin : data_in
        (* keep *)
        gf180mcu_fd_io__in_c pad (
            `ifdef USE_POWER_PINS
            .DVDD   (VDD),
            .DVSS   (VSS),
            .VDD    (VDD),
            .VSS    (VSS),
            `endif
        
            .Y      (data_in_PAD2CORE[i]),
            .PAD    (data_in_PAD[i]),
            
			.PU     (1'b0),
			.PD     (1'b0)
        );
    end
    endgenerate

    // Normal outputs using bidirectional IO cells
    generate
    for (genvar i=0; i<bits_per_cycle; i++) begin : data_out
        (* keep *)
        gf180mcu_fd_io__bi_24t pad (
            `ifdef USE_POWER_PINS
            .DVDD   (VDD),
            .DVSS   (VSS),
            .VDD    (VDD),
            .VSS    (VSS),
            `endif
        
            .A      (data_out_CORE2PAD[i]),
            .OE     (1'b1),
            .Y      (),
            .PAD    (data_out_PAD[i]),
            
            .CS     (1'b0),
            .SL     (1'b0),
            .IE     (1'b0),

			.PU     (1'b0),
			.PD     (1'b0)
        );
    end
    endgenerate

    // Core design
    Cloneless toplevel #(bits_per_cycle)
	(
       `ifdef USE_POWER_PINS
        .VSS            (VSS),
        .VDD            (VDD),
        `endif
        .clk            (clk_PAD2CORE),
        .rst            (rst_PAD2CORE),
        .seed_reg_en    (seed_reg_en_PAD2CORE),
        .triv_rst		(triv_rst_PAD2CORE),
        .triv_en        (triv_en_PAD2CORE),
        .data_in        (data_in_PAD2CORE),
        .data_out       (data_out_CORE2PAD)
    );
    
    // Do not remove, necessary for tapeout
    (* keep *) gf180mcu_ws_ip__qrcode_id qrcode_id ();
    (* keep *) gf180mcu_ws_ip__shuttle_id shuttle_id ();
    (* keep *) gf180mcu_ws_ip__project_id project_id ();
    (* keep *) gf180mcu_ws_ip__marker marker ();
    
    // wafer.space logo - can be removed if desired
    (* keep *) gf180mcu_ws_ip__logo wafer_space_logo ();

endmodule

`default_nettype wire