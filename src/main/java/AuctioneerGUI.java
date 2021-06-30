import java.awt.BorderLayout;

import jason.architecture.*;
import jason.asSemantics.ActionExec;
import jason.asSyntax.ASSyntax;
import jason.asSyntax.Literal;

import javax.swing.*;

public class AuctioneerGUI extends AgArch {

    JTextArea jt;
    JFrame    f;
    JButton auction;

    int auctionId = 0;

    public AuctioneerGUI() {
        jt = new JTextArea(10, 30);
        auction = new JButton("Inizia nuova asta");
        auction.addActionListener(e -> {
            auctionId++;
            Literal goal = ASSyntax.createLiteral("start_auction", ASSyntax.createNumber(auctionId));
            getTS().getC().addAchvGoal(goal, null);
            auction.setEnabled(false);
        });

        f = new JFrame("Battitore d'asta");
        f.getContentPane().setLayout(new BorderLayout());
        f.getContentPane().add(BorderLayout.CENTER, new JScrollPane(jt));
        f.getContentPane().add(BorderLayout.SOUTH, auction);
        f.pack();
        f.setVisible(true);
    }

    @Override
    public void act(ActionExec action) {
        if (action.getActionTerm().getFunctor().startsWith("show_winner")) {
            jt.append("Il vincitore dell'asta " + action.getActionTerm().getTerm(0));
            jt.append(" e' " + action.getActionTerm().getTerm(1) + "\n");
            action.setResult(true);
            actionExecuted(action);

            auction.setEnabled(true);
        } else if (action.getActionTerm().getFunctor().startsWith("stop_auction")) {
            jt.append("L'asta " + action.getActionTerm().getTerm(0));
            jt.append(" e' terminata senza vincitori!" + "\n");
            action.setResult(true);
            actionExecuted(action);

            auction.setEnabled(true);
        } else {
            super.act(action);
        }
    }

    @Override
    public void stop() {
        f.dispose();
        super.stop();
    }
}
