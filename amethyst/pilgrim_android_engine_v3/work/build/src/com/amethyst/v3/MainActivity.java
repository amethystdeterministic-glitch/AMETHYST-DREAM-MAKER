package com.amethyst.v3;

import android.app.Activity;
import android.os.Bundle;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.view.View;

public class MainActivity extends Activity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);

        TextView tv = new TextView(this);
        tv.setText("V3 Engine Ready");

        Button btn = new Button(this);
        btn.setText("Activate");

        btn.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                tv.setText("Pilgrim Triggered");
            }
        });

        layout.addView(tv);
        layout.addView(btn);

        setContentView(layout);
    }
}
